import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../logic/input_sanitizer.dart';

/// One chat message ('user' or 'assistant').
class ChatMessage {
  final String role;
  final String text;

  const ChatMessage(this.role, this.text);

  bool get isUser => role == 'user';
}

/// Thrown with a message that is safe and friendly to show to the player.
class AssistantException implements Exception {
  final String message;

  /// Seconds until the player may try again (rate limit), if known.
  final int? retryAfterSeconds;

  const AssistantException(this.message, {this.retryAfterSeconds});

  @override
  String toString() => message;
}

/// AI helper powered by the free tier of the Groq API
/// (OpenAI-compatible chat completions endpoint).
///
/// The API key is NOT stored in the source code. It is read at build time
/// from `secrets.json` in the project folder (git-ignored; copy
/// `secrets.example.json`). VS Code passes it automatically through
/// `.vscode/launch.json`; from a terminal use:
///   flutter run --dart-define-from-file=secrets.json
/// Optionally add "GROQ_MODEL" to the same file (default openai/gpt-oss-20b).
///
/// Groq retires models from time to time. When the chosen model no longer
/// exists, the next one in [_fallbackModels] is tried automatically and
/// remembered for the rest of the session.
///
/// Free-tier limits are protected twice:
///   1. On the device: at most [_maxRequestsPerMinute] requests per minute and
///      [_minGap] between two requests, so a player cannot flood the API.
///   2. From Groq: HTTP 429 responses are turned into a friendly message
///      with the wait time from the `retry-after` header.
class AiAssistantService {
  AiAssistantService._();

  static final AiAssistantService instance = AiAssistantService._();

  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _configuredModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'openai/gpt-oss-20b',
  );

  /// Tried in order when a model is missing or retired on Groq.
  static const List<String> _fallbackModels = [
    'openai/gpt-oss-20b',
    'openai/gpt-oss-120b',
    'qwen/qwen3.8-27b',
  ];

  /// Models to try, best first, without duplicates.
  List<String> get _models => {
        if (_workingModel != null) _workingModel!,
        _configuredModel,
        ..._fallbackModels,
      }.where((m) => !_missingModels.contains(m)).toList();

  String? _workingModel;
  final Set<String> _missingModels = {};

  static final Uri _endpoint =
      Uri.parse('https://api.groq.com/openai/v1/chat/completions');

  static const int maxInputLength = 500;
  static const int _maxHistory = 10;
  static const int _maxRequestsPerMinute = 10;
  static const Duration _minGap = Duration(seconds: 3);
  static const Duration _timeout = Duration(seconds: 30);

  static const String _systemPrompt =
      'You are NEON XO Assistant, a friendly helper inside a neon '
      'tic-tac-toe mobile game. Help with tic-tac-toe rules, strategy '
      'and tips, and with the app: difficulties Easy/Medium/Hard, up to '
      '1000 levels per difficulty, VS COMPUTER and VS FRIEND modes, undo, '
      'hints, watching a short ad for an extra undo, leaderboard, profile bio, '
      'settings and voice assistant. Gestures on the game board: swipe '
      'left = undo, swipe right = hint, double-tap the top bar = repeat '
      'the game status aloud. Keep answers short (under 120 words), '
      'simple and positive. Politely decline unrelated or unsafe requests. '
      'Never ask for passwords or personal data.';

  final List<DateTime> _recentRequests = [];
  DateTime? _blockedUntil;

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Seconds the player still has to wait, or 0.
  int get cooldownSeconds {
    final until = _blockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds;
    return left > 0 ? left + 1 : 0;
  }

  void _checkLocalLimits() {
    final wait = cooldownSeconds;
    if (wait > 0) {
      throw AssistantException(
        'The assistant is taking a short break. '
        'Please try again in $wait seconds.',
        retryAfterSeconds: wait,
      );
    }

    final now = DateTime.now();
    _recentRequests.removeWhere(
      (t) => now.difference(t) > const Duration(minutes: 1),
    );

    if (_recentRequests.isNotEmpty &&
        now.difference(_recentRequests.last) < _minGap) {
      throw const AssistantException(
        'Slow down a little! Wait a moment before sending another message.',
        retryAfterSeconds: 3,
      );
    }

    if (_recentRequests.length >= _maxRequestsPerMinute) {
      final wait =
          60 - now.difference(_recentRequests.first).inSeconds.clamp(0, 59);
      _blockedUntil = now.add(Duration(seconds: wait));
      throw AssistantException(
        "You've sent a lot of questions. "
        'Please wait $wait seconds and ask again.',
        retryAfterSeconds: wait,
      );
    }

    _recentRequests.add(now);
  }

  int? _parseRetryAfter(HttpClientResponse response) {
    final header = response.headers.value('retry-after');
    if (header == null) return null;
    final seconds = double.tryParse(header);
    if (seconds == null) return null;
    return seconds.ceil().clamp(1, 3600);
  }

  /// True when Groq says the model does not exist or was retired.
  static bool _isModelUnavailable(int status, String body) {
    if (status != 404 && status != 400) return false;
    return body.contains('model_not_found') ||
        body.contains('model_decommissioned') ||
        body.contains('decommissioned') ||
        (status == 404 && body.contains('does not exist'));
  }

  /// Sends [question] with the recent [history] and returns the answer.
  Future<String> ask(String question, List<ChatMessage> history) async {
    if (!isConfigured) {
      throw const AssistantException(
        'The AI assistant is not set up yet. Ask the developer to add a '
        'Groq API key (GROQ_API_KEY).',
      );
    }

    final text = InputSanitizer.clean(question, maxLength: maxInputLength);
    if (text.isEmpty) {
      throw const AssistantException('Please type a question first.');
    }

    _checkLocalLimits();

    final recent = history.length > _maxHistory
        ? history.sublist(history.length - _maxHistory)
        : history;

    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      for (final m in recent)
        {
          'role': m.role,
          'content': InputSanitizer.clean(m.text, maxLength: 1500),
        },
      {'role': 'user', 'content': text},
    ];

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

    try {
      late HttpClientResponse response;
      late String responseText;

      final candidates = _models;
      if (candidates.isEmpty) {
        throw const AssistantException(
          'The assistant is being updated. Please try again later.',
        );
      }

      for (final model in candidates) {
        final body = jsonEncode({
          'model': model,
          'temperature': 0.6,
          // Reasoning models (gpt-oss, qwen3) also spend tokens thinking.
          'max_tokens': 800,
          if (model.startsWith('openai/gpt-oss')) 'reasoning_effort': 'low',
          'messages': messages,
        });

        final request = await client.postUrl(_endpoint).timeout(_timeout);
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $_apiKey');
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(body));

        response = await request.close().timeout(_timeout);
        responseText =
            await response.transform(utf8.decoder).join().timeout(_timeout);

        if (_isModelUnavailable(response.statusCode, responseText)) {
          if (kDebugMode) debugPrint('Groq model unavailable: $model');
          _missingModels.add(model);
          if (_workingModel == model) _workingModel = null;
          continue;
        }
        if (response.statusCode == 200) _workingModel = model;
        break;
      }

      if (_isModelUnavailable(response.statusCode, responseText)) {
        throw const AssistantException(
          'The assistant is being updated. Please try again later.',
        );
      }

      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(responseText) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          final content = choices != null && choices.isNotEmpty
              ? (choices.first['message']?['content'] as String?)
              : null;
          if (content == null || content.trim().isEmpty) {
            throw const AssistantException(
              "I couldn't think of an answer. Please try asking differently.",
            );
          }
          return content.trim();

        case 429:
          final wait = _parseRetryAfter(response) ?? 30;
          _blockedUntil = DateTime.now().add(Duration(seconds: wait));
          throw AssistantException(
            'The assistant is very popular right now and reached its free '
            'usage limit. Please try again in $wait seconds.',
            retryAfterSeconds: wait,
          );

        case 401:
        case 403:
          throw const AssistantException(
            'The assistant is not available right now (access problem). '
            'Please try again later.',
          );

        case 413:
          if (kDebugMode) debugPrint('Groq error ${response.statusCode}: $responseText');
          throw const AssistantException(
            "Sorry, that conversation got too long. Try a shorter question.",
          );

        case 400:
          if (kDebugMode) debugPrint('Groq error 400: $responseText');
          throw const AssistantException(
            "Sorry, I couldn't handle that question. Try asking differently.",
          );

        default:
          if (kDebugMode) debugPrint('Groq error ${response.statusCode}: $responseText');
          throw const AssistantException(
            'The assistant service is busy. Please try again in a minute.',
          );
      }
    } on AssistantException {
      rethrow;
    } on TimeoutException {
      throw const AssistantException(
        'The assistant took too long to answer. Please try again.',
      );
    } on SocketException {
      throw const AssistantException(
        'No internet connection. Connect and try again.',
      );
    } on HandshakeException {
      throw const AssistantException(
        'A secure connection could not be made. Please try again later.',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Assistant error: $e');
      throw const AssistantException(
        'Something went wrong. Please try again.',
      );
    } finally {
      client.close(force: true);
    }
  }
}
