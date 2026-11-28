import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encrypted replacement for [SharedPreferences].
///
/// Everything is kept as one JSON value inside [FlutterSecureStorage], which
/// on Android is encrypted with AES-GCM using a key held in the Android
/// Keystore. Because it is one value, the key names (which contain emails and
/// phone numbers) are encrypted too, not just the values.
///
/// It has the same get/set/remove methods the app used on SharedPreferences.
/// On first use, any data left in the old plain SharedPreferences file is
/// moved into secure storage and then deleted from the plain file.
class SecurePrefs {
  SecurePrefs._(this._storage, this._values);

  static const String _storageKey = 'neon_xo_prefs_v1';

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage();

  static Future<SecurePrefs>? _instance;

  final FlutterSecureStorage _storage;
  final Map<String, Object> _values;

  // Writes run one after another so a slow write never overwrites a newer one.
  Future<void> _pendingWrite = Future.value();

  static Future<SecurePrefs> getInstance() {
    return _instance ??= _load(_defaultStorage);
  }

  /// For tests: starts with [values] in the old plain SharedPreferences, so
  /// the migration into secure storage runs exactly as on a real device.
  @visibleForTesting
  static void setMockInitialValues(Map<String, Object> values) {
    // ignore: invalid_use_of_visible_for_testing_member
    FlutterSecureStorage.setMockInitialValues({});
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(values);
    _instance = null;
  }

  static Future<SecurePrefs> _load(FlutterSecureStorage storage) async {
    final values = <String, Object>{};

    final saved = await storage.read(key: _storageKey);
    if (saved != null && saved.isNotEmpty) {
      final decoded = jsonDecode(saved);
      if (decoded is Map<String, dynamic>) {
        decoded.forEach((key, value) {
          if (value != null) values[key] = value as Object;
        });
      }
    }

    final prefs = SecurePrefs._(storage, values);
    await prefs._migrateFromPlainPrefs();
    return prefs;
  }

  /// Moves old unencrypted values into secure storage, then deletes them.
  Future<void> _migrateFromPlainPrefs() async {
    final plain = await SharedPreferences.getInstance();
    final keys = plain.getKeys();
    if (keys.isEmpty) return;

    for (final key in keys) {
      final value = plain.get(key);
      // Values already in secure storage are newer; keep them.
      if (value != null && !_values.containsKey(key)) {
        _values[key] = value is List ? List<String>.from(value) : value;
      }
    }

    // Save the encrypted copy first, so nothing is lost if the app is
    // closed half way through.
    await _persist();
    await plain.clear();
  }

  Future<bool> _persist() {
    final snapshot = jsonEncode(_values);
    final write = _pendingWrite.then(
      (_) => _storage.write(key: _storageKey, value: snapshot),
    );
    _pendingWrite = write.catchError((_) {});
    return write.then((_) => true);
  }

  String? getString(String key) {
    final value = _values[key];
    return value is String ? value : null;
  }

  int? getInt(String key) {
    final value = _values[key];
    return value is int ? value : null;
  }

  bool? getBool(String key) {
    final value = _values[key];
    return value is bool ? value : null;
  }

  Future<bool> setString(String key, String value) {
    _values[key] = value;
    return _persist();
  }

  Future<bool> setInt(String key, int value) {
    _values[key] = value;
    return _persist();
  }

  Future<bool> setBool(String key, bool value) {
    _values[key] = value;
    return _persist();
  }

  Future<bool> remove(String key) {
    if (_values.remove(key) == null) return Future.value(true);
    return _persist();
  }
}
