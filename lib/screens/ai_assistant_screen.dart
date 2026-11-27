import 'dart:async';

import 'package:flutter/material.dart';

import '../services/ai_assistant_service.dart';
import '../services/audio_service.dart';
import '../services/voice_assistant_service.dart';
import '../theme/app_theme.dart';

/// Chat with the AI assistant (Groq). Rate limits are shown as friendly
/// banners instead of errors.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AiAssistantService _assistant = AiAssistantService.instance;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<ChatMessage> _messages = [
    const ChatMessage(
      'assistant',
      "Hi! I'm the NEON XO Assistant. Ask me about rules, strategy, "
          'levels or how to use the app.',
    ),
  ];

  static const List<String> _suggestions = [
    'How can I beat Hard mode?',
    'What is the best first move?',
    'How do levels work?',
  ];

  bool _sending = false;
  String? _notice;
  Timer? _cooldownTimer;
  int _cooldown = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) {
          _cooldown = 0;
          _notice = null;
          t.cancel();
        }
      });
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending || _cooldown > 0) return;

    AudioService.playButtonSound();

    // History sent to the API: everything except the greeting.
    final history = _messages.skip(1).toList();

    setState(() {
      _messages.add(ChatMessage('user', text));
      _sending = true;
      _notice = null;
      _input.clear();
    });
    _scrollToEnd();

    try {
      final answer = await _assistant.ask(text, history);
      if (!mounted) return;
      setState(() => _messages.add(ChatMessage('assistant', answer)));
      unawaited(VoiceAssistantService.instance.speak(answer));
    } on AssistantException catch (e) {
      if (!mounted) return;
      // Give the question back so the player does not have to retype it.
      setState(() {
        _messages.removeLast();
        _input.text = text;
        _notice = e.message;
      });
      unawaited(VoiceAssistantService.instance.speak(e.message));
      if (e.retryAfterSeconds != null) _startCooldown(e.retryAfterSeconds!);
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  Widget _bubble(ChatMessage m) {
    final color = m.isUser ? AppTheme.neonCyan : AppTheme.neonPink;

    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        label: m.isUser ? 'You said' : 'Assistant said',
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
          ),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(150)),
          ),
          child: SelectableText(m.text, style: const TextStyle(height: 1.4)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !_sending && _cooldown == 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'AI Assistant',
          style: TextStyle(color: AppTheme.neonCyan),
        ),
        iconTheme: const IconThemeData(color: AppTheme.neonCyan),
      ),
      // resizeToAvoidBottomInset (default) keeps the input above the keyboard.
      body: SafeArea(
        child: Column(
          children: [
            if (!_assistant.isConfigured)
              const _Banner(
                icon: Icons.info_outline,
                color: AppTheme.neonYellow,
                text: 'The assistant needs a Groq API key. Build the app with '
                    '--dart-define=GROQ_API_KEY=your_key',
              ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Assistant is typing...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }
                  return _bubble(_messages[i]);
                },
              ),
            ),
            if (_notice != null)
              Semantics(
                liveRegion: true,
                child: _Banner(
                  icon: Icons.hourglass_top,
                  color: AppTheme.neonYellow,
                  text: _cooldown > 0
                      ? '$_notice\n(ready in $_cooldown s)'
                      : _notice!,
                ),
              ),
            if (_messages.length == 1)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final s in _suggestions)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(
                          label: Text(s),
                          onPressed: canSend ? () => _send(s) : null,
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      maxLength: AiAssistantService.maxInputLength,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask something...',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: canSend ? () => _send() : null,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Banner({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
