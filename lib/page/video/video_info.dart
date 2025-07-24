import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:async';

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
                  GestureDetector(
                    onTap: _toggleControls,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: controller,
                        controls: null, // 禁用默认控件
                      ),
                    ),
                  ),

                  // 顶部控制栏
                  if (_showControls)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            // 返回按钮
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            // 标题
                            Expanded(
                              child: Text(
                                widget.videoTitle ?? '视频标题',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 设置按钮
                            IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: 打开设置菜单
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 底部控制栏
                  if (_showControls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: StreamBuilder<Duration>(
                          stream: player.stream.position,
                          builder: (context, positionSnapshot) {
                            return StreamBuilder<Duration>(
                              stream: player.stream.duration,
                              builder: (context, durationSnapshot) {
                                final position =
                                    positionSnapshot.data ?? Duration.zero;
                                final duration =
                                    durationSnapshot.data ?? Duration.zero;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 时间显示
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          formatDuration(
                                            _isDragging
                                                ? _dragPosition
                                                : position,
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          ' / ',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          formatDuration(duration),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // 播放/暂停按钮
                                        StreamBuilder<bool>(
                                          stream: player.stream.playing,
                                          builder: (context, snapshot) {
                                            final isPlaying =
                                                snapshot.data ?? false;
                                            return IconButton(
                                              iconSize: 35,
                                              icon: Icon(
                                                isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                if (isPlaying) {
                                                  player.pause();
                                                } else {
                                                  player.play();
                                                }
                                                _showControlsTemporarily();
                                              },
                                            );
                                          },
                                        ),

                                        // 进度条区域
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              // 缓冲进度条
                                              StreamBuilder<Duration>(
                                                stream: player.stream.buffer,
                                                builder: (context, bufferSnapshot) {
                                                  final buffer =
                                                      bufferSnapshot.data ??
                                                      Duration.zero;
                                                  final bufferProgress =
                                                      duration.inMilliseconds >
                                                          0
                                                      ? (buffer.inMilliseconds /
                                                                duration
                                                                    .inMilliseconds)
                                                            .clamp(0.0, 1.0)
                                                      : 0.0;

                                                  return Container(
                                                    height: 4.0,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24.0,
                                                          vertical: 22.0,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2.0,
                                                          ),
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                    ),
                                                    child: FractionallySizedBox(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      widthFactor:
                                                          bufferProgress,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2.0,
                                                              ),
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              // 主进度条
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                      activeTrackColor:
                                                          Colors.white,
                                                      inactiveTrackColor:
                                                          Colors.transparent,
                                                      thumbColor: Colors.white,
                                                      overlayColor: Colors.white
                                                          .withOpacity(0.3),
                                                      trackHeight: 4.0,
                                                      thumbShape:
                                                          RoundSliderThumbShape(
                                                            enabledThumbRadius:
                                                                _isDragging
                                                                ? 10.0
                                                                : 8.0,
                                                          ),
                                                    ),
                                                child: Slider(
                                                  value:
                                                      duration.inMilliseconds >
                                                          0
                                                      ? (_isDragging
                                                            ? _dragPosition
                                                                  .inMilliseconds
                                                                  .toDouble()
                                                                  .clamp(
                                                                    0.0,
                                                                    duration
                                                                        .inMilliseconds
                                                                        .toDouble(),
                                                                  )
                                                            : position
                                                                  .inMilliseconds
                                                                  .toDouble()
                                                                  .clamp(
                                                                    0.0,
                                                                    duration
                                                                        .inMilliseconds
                                                                        .toDouble(),
                                                                  ))
                                                      : 0.0,
                                                  min: 0.0,
                                                  max:
                                                      duration.inMilliseconds >
                                                          0
                                                      ? duration.inMilliseconds
                                                            .toDouble()
                                                      : 1.0,
                                                  onChangeStart:
                                                      duration.inMilliseconds >
                                                          0
                                                      ? (value) {
                                                          _hideControlsTimer
                                                              ?.cancel();
                                                          setState(() {
                                                            _isDragging = true;
                                                            _showControls =
                                                                true;
                                                            _dragPosition =
                                                                Duration(
                                                                  milliseconds:
                                                                      value
                                                                          .toInt(),
                                                                );
                                                          });
                                                        }
                                                      : null,
                                                  onChanged:
                                                      duration.inMilliseconds >
                                                          0
                                                      ? (value) {
                                                          setState(() {
                                                            _dragPosition =
                                                                Duration(
                                                                  milliseconds:
                                                                      value
                                                                          .toInt(),
                                                                );
                                                          });
                                                        }
                                                      : null,
                                                  onChangeEnd:
                                                      duration.inMilliseconds >
                                                          0
                                                      ? (value) {
                                                          player.seek(
                                                            Duration(
                                                              milliseconds:
                                                                  value.toInt(),
                                                            ),
                                                          );
                                                          setState(() {
                                                            _isDragging = false;
                                                          });
                                                          _startHideControlsTimer();
                                                        }
                                                      : null,
                                                ),
                                              ),

                                              // 拖拽时显示时间预览
                                              if (_isDragging)
                                                Positioned(
                                                  top: -35,
                                                  left: 0,
                                                  right: 0,
                                                  child: Center(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8.0,
                                                            vertical: 4.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4.0,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        formatDuration(
                                                          _dragPosition,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // 全屏按钮
                                        IconButton(
                                          iconSize: 35,
                                          icon: const Icon(
                                            Icons.fullscreen,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            // TODO: 实现全屏功能
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
