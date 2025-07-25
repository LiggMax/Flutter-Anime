import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:async';
import 'controls.dart';

class VideoInfoPage extends StatefulWidget {
  final String? videoUrl;
  final String? videoTitle;

  const VideoInfoPage({super.key, this.videoUrl, this.videoTitle});

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

    // 初始化VideoController
    controller = VideoController(player);

    // 添加播放器状态监听，用于调试
    player.stream.error.listen((error) {
      print('播放器错误: $error');
    });

    player.stream.log.listen((log) {
      print('播放器日志: $log');
    });

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
    _hideControlsTimer = Timer(const Duration(seconds: 100), () {
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
                    child: Container(
                      color: Colors.black,
                      child: StreamBuilder<bool>(
                        stream: player.stream.buffering,
                        builder: (context, bufferingSnapshot) {
                          final isBuffering = bufferingSnapshot.data ?? true;

                          return Stack(
                            children: [
                              Video(
                                controller: controller,
                                controls: null, // 禁用默认控件
                                // 为 Android 添加额外配置
                                aspectRatio: 16 / 9,
                                fill: Colors.black,
                              ),
                              // 加载指示器
                              if (isBuffering)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                   StreamBuilder<bool>(
                     stream: player.stream.playing,
                     builder: (context, playingSnapshot) {
                       return StreamBuilder<Duration>(
                         stream: player.stream.position,
                         builder: (context, positionSnapshot) {
                           return StreamBuilder<Duration>(
                             stream: player.stream.duration,
                             builder: (context, durationSnapshot) {
                               return StreamBuilder<Duration>(
                                 stream: player.stream.buffer,
                                 builder: (context, bufferSnapshot) {
                                   final isPlaying = playingSnapshot.data ?? false;
                                   final position = positionSnapshot.data ?? Duration.zero;
                                   final duration = durationSnapshot.data ?? Duration.zero;
                                   final buffer = bufferSnapshot.data ?? Duration.zero;

                                   return Positioned.fill(
                                     child: VideoPlayerControls(
                                       player: player,
                                       showControls: _showControls,
                                       isDragging: _isDragging,
                                       dragPosition: _dragPosition,
                                       title: widget.videoTitle,
                                       isPlaying: isPlaying,
                                       position: position,
                                       duration: duration,
                                       buffer: buffer,
                                       onTap: _toggleControls,
                                       onBack: () => Navigator.of(context).pop(),
                                       onSettings: () {
                                         // TODO: 打开设置菜单
                                       },
                                       onPlayPause: () {
                                         if (isPlaying) {
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
                                   );
                                 },
                               );
                             },
                           );
                         },
                       );
                     },
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
