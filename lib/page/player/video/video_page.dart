/*
  @Author Ligg
  @Time 2025/7/29
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:async';
import '../controls.dart';

class VideoPage extends StatefulWidget {
  final int? animeId;
  final String? animeName;
  final Widget? contentWidget; // 视频下方的内容组件

  const VideoPage({
    super.key,
    this.animeId,
    this.animeName,
    this.contentWidget,
  });

  @override
  State<VideoPage> createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  late final Player player;
  late final VideoController controller;
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isFullscreen = false;
  bool _isTransitioning = false; // 防止连续快速切换

  // 播放状态管理
  String _playStatus = '等待选择视频中'; // 播放状态文本
  bool _isLoadingVideo = false; // 是否正在加载视频
  bool _hasVideoUrl = false; // 是否有视频URL
  bool _isParsingVideo = false; // 是否正在解析视频

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

    // 开始自动隐藏控件的计时器
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    // 恢复系统UI设置
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

  // 播放视频
  void _playVideo(String videoUrl) {
    try {
      print('开始播放视频: $videoUrl');

      setState(() {
        _isLoadingVideo = true;
        _playStatus = '解析成功，开始播放';
        _hasVideoUrl = true;
      });

      player.open(Media(videoUrl));
      player.play();

      // 监听播放状态变化
      player.stream.playing.listen((isPlaying) {
        if (mounted) {
          setState(() {
            if (isPlaying) {
              _playStatus = '正在播放';
              _isLoadingVideo = false;
            } else {
              _playStatus = '已暂停';
              _isLoadingVideo = false;
            }
          });
        }
      });

      // 监听错误
      player.stream.error.listen((error) {
        if (mounted) {
          setState(() {
            _playStatus = '播放失败: $error';
            _isLoadingVideo = false;
          });
        }
      });
    } catch (e) {
      print('播放视频失败: $e');
      setState(() {
        _playStatus = '播放失败: $e';
        _isLoadingVideo = false;
      });
    }
  }

  // 开始解析视频
  void _startParsingVideo() {
    setState(() {
      _isParsingVideo = true;
      _playStatus = '正在解析资源...';
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _toggleFullscreen() async {
    // 防止连续快速切换
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
      _showControls = false;
    });
    _hideControlsTimer?.cancel();

    try {
      if (!_isFullscreen) {
        // 进入全屏
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        // 等待屏幕旋转完成
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        // 退出全屏
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // 等待屏幕旋转和布局重建完成
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 更新全屏状态
      setState(() {
        _isFullscreen = !_isFullscreen;
      });
      // 再次等待确保布局稳定
      await Future.delayed(const Duration(milliseconds: 200));
    } finally {
      // 显示控件并重新开始计时
      setState(() {
        _showControls = true;
        _isTransitioning = false;
      });
      _startHideControlsTimer();
    }
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
        body: StreamBuilder<bool>(
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

                        return _isFullscreen
                            ? _buildFullscreenPlayer(
                                isPlaying,
                                position,
                                duration,
                                buffer,
                              )
                            : SafeArea(
                                child: Column(
                                  children: [
                                    // 视频播放器 - 保持16:9比例
                                    Flexible(
                                      flex: 0,
                                      child: _buildVideoPlayer(
                                        isPlaying,
                                        position,
                                        duration,
                                        buffer,
                                      ),
                                    ),

                                    // 视频下方的内容区域
                                    if (widget.contentWidget != null)
                                      Expanded(
                                        child: Container(
                                          color: Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                          child: widget.contentWidget!,
                                        ),
                                      ),
                                  ],
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
      ),
    );
  }

  Widget _buildVideoPlayer(
    bool isPlaying,
    Duration position,
    Duration duration,
    Duration buffer,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: constraints.maxWidth,
                color: Colors.black,
                child: _hasVideoUrl
                    ? StreamBuilder<bool>(
                        stream: player.stream.buffering,
                        builder: (context, bufferingSnapshot) {
                          final isBuffering = bufferingSnapshot.data ?? true;

                          return Stack(
                            children: [
                              Video(
                                controller: controller,
                                controls: null, // 禁用默认控件
                                aspectRatio: 16 / 9,
                                fill: Colors.black,
                                width: constraints.maxWidth,
                                height: constraints.maxWidth * 9 / 16,
                              ),
                              // 加载指示器
                              if (isBuffering || _isLoadingVideo)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          );
                        },
                      )
                    : Container(color: Colors.black), // 空容器，等待状态由控件组件处理
              ),
            ),

            _buildVideoControls(isPlaying, position, duration, buffer),
          ],
        );
      },
    );
  }

  Widget _buildFullscreenPlayer(
    bool isPlaying,
    Duration position,
    Duration duration,
    Duration buffer,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _hasVideoUrl
                ? StreamBuilder<bool>(
                    stream: player.stream.buffering,
                    builder: (context, bufferingSnapshot) {
                      final isBuffering = bufferingSnapshot.data ?? true;

                      return Stack(
                        children: [
                          Video(
                            controller: controller,
                            controls: null, // 禁用默认控件
                            fill: Colors.black,
                          ),
                          // 加载指示器
                          if (isBuffering || _isLoadingVideo)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      );
                    },
                  )
                : Container(color: Colors.black), // 空容器，等待状态由控件组件处理
          ),
        ),

        _buildVideoControls(isPlaying, position, duration, buffer),
      ],
    );
  }

  Widget _buildVideoControls(
    bool isPlaying,
    Duration position,
    Duration duration,
    Duration buffer,
  ) {
    return Positioned.fill(
      child: VideoPlayerControls(
        key: ValueKey('controls_$_isFullscreen'), // 确保全屏切换时重建
        player: player,
        showControls: _showControls,
        isDragging: _isDragging,
        dragPosition: _dragPosition,
        title: widget.animeName,
        isPlaying: isPlaying,
        position: position,
        duration: duration,
        buffer: buffer,
        isFullscreen: _isFullscreen,
        hasVideoUrl: _hasVideoUrl,
        isLoadingVideo: _isLoadingVideo,
        isParsingVideo: _isParsingVideo,
        playStatus: _playStatus,
        onTap: _toggleControls,
        onBack: _isFullscreen
            ? _toggleFullscreen
            : () => Navigator.of(context).pop(),
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
        onFullscreen: _isTransitioning ? null : _toggleFullscreen,
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
  }

  // 暴露给外部的方法
  void playVideo(String videoUrl) => _playVideo(videoUrl);
  void startParsingVideo() => _startParsingVideo();
}
