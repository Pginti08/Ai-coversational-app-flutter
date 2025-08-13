import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  factory LocalStorageService() {
    return instance;
  }

  LocalStorageService._internal();
  static final LocalStorageService instance = LocalStorageService._internal();
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    await _prefs?.setString(key, json.encode(value));
  }

  dynamic getObject(String key) {
    final data = _prefs?.getString(key);
    return data != null ? json.decode(data) : null;
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
