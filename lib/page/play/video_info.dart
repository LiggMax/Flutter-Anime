import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:async';
import 'comments.dart';
import 'controls.dart';
import 'details_info.dart';

class VideoInfoPage extends StatefulWidget {
  final int? animeId;
  final String? animeName;

  const VideoInfoPage({
    super.key,
    this.animeId,
    this.animeName,
  });

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
  bool _isFullscreen = false;
  bool _isTransitioning = false; // 防止连续快速切换
  String? _currentVideoUrl; // 当前播放的视频URL

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

    print('接收到的id${widget.animeId}');
    print('接收到的标题${widget.animeName}');

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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

  // 处理接收到的视频URL
  void _onVideoUrlReceived(String videoUrl) {
    print('接收到视频URL: $videoUrl');
    
    // 检查URL格式是否正确
    if (videoUrl.contains(r'\/')) {
      print('检测到转义字符，进行URL清理...');
      final cleanedUrl = videoUrl.replaceAll(r'\/', '/');
      print('清理后的URL: $cleanedUrl');
      setState(() {
        _currentVideoUrl = cleanedUrl;
      });
      _playVideo(cleanedUrl);
    } else {
      setState(() {
        _currentVideoUrl = videoUrl;
      });
      _playVideo(videoUrl);
    }
  }

  // 播放视频
  void _playVideo(String videoUrl) {
    try {
      print('开始播放视频: $videoUrl');
      player.open(Media(videoUrl));
      player.play();
    } catch (e) {
      print('播放视频失败: $e');
    }
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
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
        );
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
                          ? _buildFullscreenPlayer(isPlaying, position, duration, buffer)
                          : SafeArea(
                              child: Column(
                                children: [
                                  // 视频播放器 - 保持16:9比例
                                  Flexible(
                                    flex: 0,
                                    child: _buildVideoPlayer(isPlaying, position, duration, buffer),
                                  ),

                                  // 视频下方的内容区域
                                  Expanded(
                                    child: Container(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      child: DefaultTabController(
                                        length: 2, // 两个标签页
                                        child: Column(
                                          children: [
                                            TabBar(
                                              tabs: [
                                                Tab(text: '详情'),
                                                Tab(text: '评论'),
                                              ],
                                            ),
                                            Expanded(
                                              child: TabBarView(
                                                children: [
                                                  DetailPage(
                                                    animeId: widget.animeId,
                                                    animeName: widget.animeName,
                                                    onVideoUrlReceived: _onVideoUrlReceived,
                                                  ), // 详情页面
                                                  CommentsPage(), // 评论页面
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
  Widget _buildVideoPlayer(bool isPlaying, Duration position, Duration duration, Duration buffer) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: constraints.maxWidth,
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
                          aspectRatio: 16 / 9,
                          fill: Colors.black,
                          width: constraints.maxWidth,
                          height: constraints.maxWidth * 9 / 16,
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

            _buildVideoControls(isPlaying, position, duration, buffer),
          ],
        );
      },
    );
  }

  Widget _buildFullscreenPlayer(bool isPlaying, Duration position, Duration duration, Duration buffer) {
    return Stack(
      children: [
        Positioned.fill(
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

        _buildVideoControls(isPlaying, position, duration, buffer),
      ],
    );
  }

  Widget _buildVideoControls(bool isPlaying, Duration position, Duration duration, Duration buffer) {
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
}
