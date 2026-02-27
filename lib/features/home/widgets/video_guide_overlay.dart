import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/features/home/controller/home_controller.dart';

class VideoGuideOverlay extends StatefulWidget {
  const VideoGuideOverlay({super.key});

  @override
  State<VideoGuideOverlay> createState() => _VideoGuideOverlayState();
}

class _VideoGuideOverlayState extends State<VideoGuideOverlay>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late AnimationController _buttonsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _buttonsSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;

  bool _isVideoCompleted = false;
  bool _isInitialized = false;

  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();

    // Fade-in animation for the entire overlay
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide-up + fade animation for the buttons
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOutCubic,
    ));
    _buttonsFadeAnimation = CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOut,
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/guide.mp4');
    await _videoController.initialize();
    _videoController.addListener(_videoListener);
    _videoController.play();

    if (mounted) {
      setState(() => _isInitialized = true);
      _fadeController.forward();
    }
  }

  void _videoListener() {
    if (!_videoController.value.isPlaying &&
        _videoController.value.isInitialized &&
        _videoController.value.position >= _videoController.value.duration &&
        !_isVideoCompleted) {
      setState(() => _isVideoCompleted = true);
      _buttonsController.forward();
    }
  }

  void _replayVideo() {
    setState(() => _isVideoCompleted = false);
    _buttonsController.reset();
    _videoController.seekTo(Duration.zero);
    _videoController.play();
  }

  void _completeGuide() {
    _homeController.hasSeenGuide.value = true;
    _homeController.markGuideSeen();
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    _fadeController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark blurred background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: topPadding * 0.2 + 16),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.colorGradient,
                    ).createShader(bounds),
                    child: Text(
                      "HOW IT WORKS",
                      style: style700S14.copyWith(
                        letterSpacing: 3.0,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Quick Guide",
                    style: style700S24.copyWith(
                      color: AppColors.whiteTextColor,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Video Player
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _isInitialized
                          ? _buildVideoPlayer()
                          : _buildVideoLoader(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress bar
                  if (_isInitialized)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _buildProgressBar(),
                    ),

                  const SizedBox(height: 20),

                  // Buttons (appear after video ends)
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorGradient[0].withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.colorGradient[0],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading guide...",
            style: style400S14.copyWith(
              color: AppColors.lightGreyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _videoController,
      builder: (context, child) {
        final duration = _videoController.value.duration;
        final position = _videoController.value.position;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        return Column(
          children: [
            // Progress bar
            Container(
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: AppColors.colorGradient,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // // Time labels
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       _formatDuration(position),
            //       style: style400S10.copyWith(
            //         color: AppColors.lightGreyTextColor,
            //       ),
            //     ),
            //     Text(
            //       _formatDuration(duration),
            //       style: style400S10.copyWith(
            //         color: AppColors.lightGreyTextColor,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    if (!_isVideoCompleted) {
      return const SizedBox(height: 56);
    }

    return SlideTransition(
      position: _buttonsSlideAnimation,
      child: FadeTransition(
        opacity: _buttonsFadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Replay button
              Expanded(
                child: AppButton(
                  text: "Replay",
                  isOutlined: true,
                  height: 50,
                  onTap: _replayVideo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.replay_rounded,
                        color: AppColors.whiteTextColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Replay",
                        style: style600S16.copyWith(
                          color: AppColors.whiteTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Complete Guide button
              Expanded(
                flex: 2,
                child: AppButton(
                  text: "Complete Guide",
                  height: 50,
                  onTap: _completeGuide,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.blackColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Complete Guide",
                        style: style700S16.copyWith(
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
