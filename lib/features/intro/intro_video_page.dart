import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_screen.dart';

class IntroVideoPage extends StatefulWidget {
  const IntroVideoPage({super.key});

  static const String routeName = '/intro';
  static const String _introAsset = 'assets/images/intro.mp4';

  @override
  State<IntroVideoPage> createState() => _IntroVideoPageState();
}

class _IntroVideoPageState extends State<IntroVideoPage> {
  late final VideoPlayerController _videoController;
  bool _isReady = false;
  bool _hasError = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(IntroVideoPage._introAsset)
      ..setLooping(false)
      ..addListener(_handleVideoProgress);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.play();
      if (!mounted) {
        return;
      }
      setState(() {
        _isReady = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = true;
      });
    }
  }

  void _handleVideoProgress() {
    if (!_videoController.value.isInitialized) {
      return;
    }

    final position = _videoController.value.position;
    final duration = _videoController.value.duration;
    if (duration > Duration.zero && position >= duration) {
      _enterApp();
    }
  }

  void _enterApp() {
    if (_isNavigating) {
      return;
    }
    _isNavigating = true;
    Get.offNamed(YoloLabPage.routeName);
  }

  @override
  void dispose() {
    _videoController
      ..removeListener(_handleVideoProgress)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF08131C),
              Color(0xFF133044),
              Color(0xFFE2B86A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildContent(theme),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 20,
              right: 20,
              child: FilledButton.tonal(
                onPressed: _enterApp,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.28),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bỏ qua'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Không thể phát video intro.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'App sẽ vào thẳng màn chính khi bạn tiếp tục.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _enterApp,
                child: const Text('Vào ứng dụng'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isReady) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Đang tải intro...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController.value.size.width,
            height: _videoController.value.size.height,
            child: VideoPlayer(_videoController),
          ),
        ),
      ),
    );
  }
}
