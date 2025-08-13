import 'package:flutter/material.dart';

class LoaderService extends ChangeNotifier {
  factory LoaderService() => instance;
  LoaderService._internal();
  static final LoaderService instance = LoaderService._internal();

  bool _isLoading = false;
  int _loadingCount = 0;

  bool get isLoading => _isLoading;

  void show() {
    _loadingCount++;
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  void hide() {
    _loadingCount--;
    if (_loadingCount <= 0) {
      _loadingCount = 0;
      _isLoading = false;
      notifyListeners();
    }
  }
}
