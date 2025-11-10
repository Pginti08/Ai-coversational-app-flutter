import 'package:get/get.dart';

enum GuideStep {
  swipeRight, // Like action
  swipeLeft, // Skip action
  pullDownShuffle, // Shuffle via pull down
  openDrawer, // Toggle drawer
  completed
}

class UserGuideService extends GetxController {
  static UserGuideService get instance => Get.find<UserGuideService>();

  final currentStep = Rx<GuideStep>(GuideStep.swipeRight);
  final showGuide = false.obs;
  final stepCompletionCount = <GuideStep, int>{}.obs;

  // Number of times user needs to repeat action before moving to next step
  static const int requiredRepetitions = 1;

  @override
  void onInit() {
    super.onInit();
    _initializeStepCounts();
  }

  void _initializeStepCounts() {
    for (var step in GuideStep.values) {
      if (step != GuideStep.completed) {
        stepCompletionCount[step] = 0;
      }
    }
  }

  void startGuide() {
    showGuide.value = true;
    currentStep.value = GuideStep.swipeRight;
    _initializeStepCounts();
  }

  void recordAction(GuideStep step) {
    if (!showGuide.value || currentStep.value != step) return;

    stepCompletionCount[step] = (stepCompletionCount[step] ?? 0) + 1;

    if (stepCompletionCount[step]! >= requiredRepetitions) {
      _moveToNextStep();
    }
  }

  void _moveToNextStep() {
    switch (currentStep.value) {
      case GuideStep.swipeRight:
        currentStep.value = GuideStep.swipeLeft;
        break;
      case GuideStep.swipeLeft:
        currentStep.value = GuideStep.pullDownShuffle;
        break;
      case GuideStep.pullDownShuffle:
        currentStep.value = GuideStep.openDrawer;
        break;
      case GuideStep.openDrawer:
        _completeGuide();
        break;
      case GuideStep.completed:
        break;
    }
  }

  void _completeGuide() {
    currentStep.value = GuideStep.completed;
    showGuide.value = false;
    // Call API here to mark guide as completed
    _callGuideCompletionApi();
  }

  Future<void> _callGuideCompletionApi() async {
    try {
      // TODO: Replace with your actual API call
      // Example:
      // await ApiService.instance.markGuideCompleted();

      // Update local storage
      // LocalStorageService.instance.userInfo.value.data?.hasSeenGuide = true;

      print("Guide completion API called successfully");
    } catch (e) {
      print("Error calling guide completion API: $e");
    }
  }

  void skipGuide() {
    showGuide.value = false;
    currentStep.value = GuideStep.completed;
    _callGuideCompletionApi();
  }

  GuideConfig getGuideConfig() {
    switch (currentStep.value) {
      case GuideStep.swipeRight:
        return GuideConfig(
          title: "SWIPE RIGHT TO LIKE",
          description:
              "Swipe the card right to save outfits you love to your favorites",
          highlightArea: HighlightArea.card,
          arrowDirection: ArrowDirection.right,
        );
      case GuideStep.swipeLeft:
        return GuideConfig(
          title: "SWIPE LEFT TO SKIP",
          description: "Swipe left to skip outfits you're not interested in",
          highlightArea: HighlightArea.card,
          arrowDirection: ArrowDirection.left,
        );
      case GuideStep.pullDownShuffle:
        return GuideConfig(
          title: "PULL DOWN TO SHUFFLE",
          description:
              "Pull down from the card and select shuffle to get fresh recommendations",
          highlightArea: HighlightArea.top,
          arrowDirection: ArrowDirection.down,
        );
      case GuideStep.openDrawer:
        return GuideConfig(
          title: "TAP TO OPEN MENU",
          description: "Access your profile, settings, and more from here",
          highlightArea: HighlightArea.profileIcon,
          arrowDirection: ArrowDirection.none,
        );
      case GuideStep.completed:
        return GuideConfig(
          title: "",
          description: "",
          highlightArea: HighlightArea.none,
          arrowDirection: ArrowDirection.none,
        );
    }
  }

  int getCurrentStepNumber() {
    switch (currentStep.value) {
      case GuideStep.swipeRight:
        return 1;
      case GuideStep.swipeLeft:
        return 2;
      case GuideStep.pullDownShuffle:
        return 3;
      case GuideStep.openDrawer:
        return 4;
      case GuideStep.completed:
        return 4;
    }
  }

  int getTotalSteps() => 4;
}

class GuideConfig {
  final String title;
  final String description;
  final HighlightArea highlightArea;
  final ArrowDirection arrowDirection;

  GuideConfig({
    required this.title,
    required this.description,
    required this.highlightArea,
    required this.arrowDirection,
  });
}

enum HighlightArea { card, top, profileIcon, none }

enum ArrowDirection { left, right, down, none }
