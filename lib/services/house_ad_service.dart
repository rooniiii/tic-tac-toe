import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../logic/input_sanitizer.dart';

/// An advertisement managed by administrators in the Admin app
/// (Firestore collection `ads`).
class HouseAd {
  static const int defaultCountdown = 15;
  static const int minCountdown = 5;
  static const int maxCountdown = 60;

  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final int countdownSeconds;

  const HouseAd({
    required this.id,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.countdownSeconds,
  });

  factory HouseAd.fromMap(String id, Map<String, dynamic> data) {
    final rawSeconds = data['countdownSeconds'];
    final seconds = rawSeconds is num
        ? rawSeconds.toInt().clamp(minCountdown, maxCountdown)
        : defaultCountdown;

    final url = data['imageUrl']?.toString();

    return HouseAd(
      id: id,
      // Never trust stored text blindly: clean and limit it again.
      title: InputSanitizer.clean(data['title']?.toString() ?? '',
          maxLength: 60),
      message: InputSanitizer.clean(data['message']?.toString() ?? '',
          maxLength: 200),
      imageUrl: InputSanitizer.isSafeHttpsUrl(url) ? url : null,
      countdownSeconds: seconds,
    );
  }
}

/// Loads active ads from Firestore and decides when one is shown.
class HouseAdService {
  HouseAdService._();

  static final HouseAdService instance = HouseAdService._();

  /// A countdown ad is shown before every Nth level.
  static const int showEveryLevels = 3;

  static const Duration _cacheTime = Duration(minutes: 10);

  final Random _random = Random();

  List<HouseAd> _cache = const [];
  DateTime? _loadedAt;
  Future<List<HouseAd>>? _loading;

  Future<List<HouseAd>> _activeAds() async {
    final loadedAt = _loadedAt;
    if (loadedAt != null && DateTime.now().difference(loadedAt) < _cacheTime) {
      return _cache;
    }

    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<List<HouseAd>> _load() async {
    try {
      // Single-field filter: no composite index needed.
      final snapshot = await FirebaseFirestore.instance
          .collection('ads')
          .where('active', isEqualTo: true)
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 8));

      _cache = snapshot.docs
          .map((doc) => HouseAd.fromMap(doc.id, doc.data()))
          .where((ad) => ad.title.isNotEmpty)
          .toList();
      _loadedAt = DateTime.now();
    } catch (e) {
      // Offline or not allowed: simply show no ad.
      if (kDebugMode) debugPrint('House ads could not be loaded: $e');
    }

    return _cache;
  }

  /// A random active ad, or null when there is none.
  Future<HouseAd?> pickAd() async {
    final ads = await _activeAds();
    if (ads.isEmpty) return null;
    return ads[_random.nextInt(ads.length)];
  }

  /// True when an ad should play before [nextLevel].
  bool shouldShowBeforeLevel(int nextLevel) =>
      nextLevel > 1 && (nextLevel - 1) % showEveryLevels == 0;

  /// Loads ads in the background so they are ready when needed.
  void preload() {
    _activeAds();
  }
}
