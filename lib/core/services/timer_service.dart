import 'dart:async';

import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  final ValueNotifier<int> count = ValueNotifier<int>(0);
  final StreamController<int> _controller = StreamController<int>.broadcast();
  bool _isActive = false;

  // Getter for the stream to listen to timer updates
  Stream<int> get timerStream => _controller.stream;

  // Initialize the timer service
  void init() {
    // Reset any existing state
    _isActive = false;
    count.value = 0;
    _timer?.cancel();
  }

  // Start the timer - begins counting from current value
  void startTimer() {
    if (_isActive) return; // Don't start if already running

    _isActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count.value++;
      if (!_controller.isClosed) {
        _controller.sink.add(count.value);
      }
    });
  }

  // Pause the timer - stops counting but retains current value
  void pauseTimer() {
    if (!_isActive) return; // Don't pause if not running

    _isActive = false;
    _timer?.cancel();
    _timer = null;
  }

  // Resume the timer - continues counting from current value
  void resumeTimer() {
    if (_isActive) return; // Don't resume if already running

    startTimer(); // Use existing start logic
  }

  // Reset timer to zero and stop
  void resetTimer() {
    pauseTimer();
    count.value = 0;
    _controller.sink.add(count.value);
  }

  // Get current timer value
  int getCurrentValue() {
    return count.value;
  }

  // Dispose resources
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
