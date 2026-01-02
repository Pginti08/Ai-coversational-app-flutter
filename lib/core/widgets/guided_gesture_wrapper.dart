import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/features/home/screens/home_screen.dart';

class GuideGestureController extends StatelessWidget {
  final Widget child;
  final Rx<GuideStep> currentGuideStep;

  // Drag-down related callbacks
  final Function(DragStartDetails)? onVerticalDragStart;
  final Function(DragUpdateDetails)? onVerticalDragUpdate;
  final Function(DragEndDetails)? onVerticalDragEnd;

  const GuideGestureController({
    Key? key,
    required this.child,
    required this.currentGuideStep,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = currentGuideStep.value;

      // Determine which gestures are allowed based on the current step
      final allowDragDown = _shouldAllowDragDown(step);

      return Stack(
        children: [
          // Always add GestureDetector for drag functionality
          GestureDetector(
            onVerticalDragStart: allowDragDown ? onVerticalDragStart : null,
            onVerticalDragUpdate: allowDragDown ? onVerticalDragUpdate : null,
            onVerticalDragEnd: allowDragDown ? onVerticalDragEnd : null,
            behavior: HitTestBehavior.opaque,
            child: child,
          ),
        ],
      );
    });
  }

  /// Determine if drag-down gesture should be allowed
  bool _shouldAllowDragDown(GuideStep step) {
    switch (step) {
      case GuideStep.none:
      case GuideStep.done:
        return true; // Always allow when guide is not active
      case GuideStep.dragDown:
      case GuideStep.thumbLeft:
      case GuideStep.thumbRight:
        return true; // Allow during drag-down tutorial steps
      case GuideStep.swipeRight:
      case GuideStep.swipeLeft:
      case GuideStep.openDrawer:
        return false; // Disable during other steps
    }
  }
}

/// Wrapper specifically for the CardSwiper to control its interactivity
class GuideCardSwiperWrapper extends StatelessWidget {
  final Widget cardSwiper;
  final Rx<GuideStep> currentGuideStep;

  const GuideCardSwiperWrapper({
    Key? key,
    required this.cardSwiper,
    required this.currentGuideStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = currentGuideStep.value;
      final isSwipeAllowed = step == GuideStep.none ||
          step == GuideStep.done ||
          step == GuideStep.swipeRight ||
          step == GuideStep.swipeLeft;

      if (!isSwipeAllowed) {
        // Block all pointer events on the card swiper
        return AbsorbPointer(
          absorbing: true,
          child: IgnorePointer(
            ignoring: true,
            child: cardSwiper,
          ),
        );
      }

      return cardSwiper;
    });
  }
}

/// Wrapper for drawer icon to control its tap interactivity
class GuideDrawerIconWrapper extends StatelessWidget {
  final Widget drawerIcon;
  final Rx<GuideStep> currentGuideStep;
  final VoidCallback onTap;
  final GlobalKey? widgetKey;

  const GuideDrawerIconWrapper({
    Key? key,
    required this.drawerIcon,
    required this.currentGuideStep,
    required this.onTap,
    this.widgetKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = currentGuideStep.value;
      final isTapAllowed = step == GuideStep.none ||
          step == GuideStep.done ||
          step == GuideStep.openDrawer;

      return GestureDetector(
        key: widgetKey,
        onTap: isTapAllowed ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: isTapAllowed
            ? drawerIcon
            : AbsorbPointer(
                absorbing: true,
                child: IgnorePointer(
                  ignoring: true,
                  child: drawerIcon,
                ),
              ),
      );
    });
  }
}
