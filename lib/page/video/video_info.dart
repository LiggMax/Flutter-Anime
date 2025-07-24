import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:async';
import 'controls.dart';

class VideoInfoPage extends StatefulWidget {
  final String? videoUrl;
  final String? videoTitle;

  const VideoInfoPage({Key? key, this.videoUrl, this.videoTitle})
    : super(key: key);

  @override
  State<VideoInfoPage> createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  late final Player player;
  late final VideoController controller;
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();

    // 创建播放器实例
    player = Player();

    // 创建视频控制器
    controller = VideoController(player);

    // 如果提供了视频URL，则开始播放
    if (widget.videoUrl != null) {
      player.open(Media(widget.videoUrl!));
    }

    // 开始自动隐藏控件的计时器
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    player.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // 视频播放器 - 保持16:9比例
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Video(
                      controller: controller,
                      controls: null, // 禁用默认控件
                    ),
                  ),
                  Positioned.fill(
                    child: VideoPlayerControls(
                      player: player,
                      showControls: _showControls,
                      isDragging: _isDragging,
                      dragPosition: _dragPosition,
                      title: widget.videoTitle,
                      onTap: _toggleControls,
                      onBack: () => Navigator.of(context).pop(),
                      onSettings: () {
                        // TODO: 打开设置菜单
                      },
                      onPlayPause: () {
                        if (player.state.playing) {
                          player.pause();
                        } else {
                          player.play();
                        }
                        _showControlsTemporarily();
                      },
                      onFullscreen: () {
                        // TODO: 实现全屏功能
                      },
                      onSeekStart: (value) {
                        _hideControlsTimer?.cancel();
                        setState(() {
                          _isDragging = true;
                          _showControls = true;
                          _dragPosition = Duration(milliseconds: value.toInt());
                        });
                      },
                      onSeekChanged: (value) {
                        setState(() {
                          _dragPosition = Duration(milliseconds: value.toInt());
                        });
                      },
                      onSeekEnd: (value) {
                        player.seek(Duration(milliseconds: value.toInt()));
                        setState(() {
                          _isDragging = false;
                        });
                        _startHideControlsTimer();
                      },
                    ),
                  ),
                ],
              ),

              // 视频下方的内容区域
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: const Center(child: Text('视频信息和评论区域')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
