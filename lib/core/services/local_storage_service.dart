import 'dart:convert';

import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/features/home/models/user_detail_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  factory LocalStorageService() {
    return instance;
  }

  LocalStorageService._internal();
  static final LocalStorageService instance = LocalStorageService._internal();
  static SharedPreferences? _prefs;

  // Create a single reactive instance that persists
  final Rx<UserDetailModel> _userInfo = UserDetailModel().obs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load user info on initialization
    _loadUserInfo();
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
    // Reset user info when clearing
    _userInfo.value = UserDetailModel();
  }

  /// Load user info from storage into reactive variable
  void _loadUserInfo() {
    final data = getObject(StorageConstants.userModel);
    if (data != null) {
      _userInfo.value = UserDetailModel.fromJson(data);
    }
  }

  /// Save User Info and update reactive variable
  void setUserInfo(UserDetailModel user) {
    saveObject(StorageConstants.userModel, user.toJson());
    // Update the reactive variable to trigger UI updates
    _userInfo.value = user;
  }

  /// Read User Info - returns the same reactive instance
  Rx<UserDetailModel> get userInfo => _userInfo;
}
