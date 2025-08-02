import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 视频播放器核心组件
class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final VoidCallback? onBackPressed;
  final bool showControls;

  const VideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.onBackPressed,
    this.showControls = false,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  // 创建播放器实例
  late final player = Player();
  // 创建视频控制器
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // 创建媒体对象
      final media = Media(widget.videoUrl);

      // 打开视频
      await player.open(media);

      // 设置播放列表模式为单曲循环
      await player.setPlaylistMode(PlaylistMode.single);

      // 设置音量
      await player.setVolume(100.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频加载失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    // 释放播放器资源
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Video(
        controller: controller,
        // 自定义播放器控件
        controls: widget.showControls ? _buildCustomControls : NoVideoControls,
      ),
    );
  }

  // 自定义播放器控件
  Widget _buildCustomControls(VideoState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 顶部控制栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 返回按钮
                  IconButton(
                    onPressed: () => Navigator.of(state.context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  // 标题
                  if (widget.title != null)
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // 设置按钮
                  IconButton(
                    onPressed: () {
                      _showSettingsDialog(
                        state.context,
                        state.widget.controller,
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部控制栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 时间显示
                StreamBuilder<Duration>(
                  stream: state.widget.controller.player.stream.position,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration =
                        state.widget.controller.player.state.duration;

                    if (duration.inSeconds == 0) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // 添加水平间隔
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),


                // 底部控制栏
                Row(
                  children: [
                    // 播放/暂停按钮
                    StreamBuilder<bool>(
                      stream: state.widget.controller.player.stream.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () =>
                              state.widget.controller.player.playOrPause(),
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 35,
                          ),
                        );
                      },
                    ),

                    // 音量控制
                    StreamBuilder<double>(
                      stream: state.widget.controller.player.stream.volume,
                      builder: (context, snapshot) {
                        final volume = snapshot.data ?? 100.0;
                        return IconButton(
                          onPressed: () {
                            final newVolume = volume > 0 ? 0.0 : 100.0;
                            state.widget.controller.player.setVolume(
                              newVolume,
                            );
                          },
                          icon: Icon(
                            volume > 0 ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),

                    // 进度条
                    Expanded(
                      child: StreamBuilder<Duration>(
                        stream:
                            state.widget.controller.player.stream.position,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration =
                              state.widget.controller.player.state.duration;

                          if (duration.inSeconds == 0) {
                            return const SizedBox.shrink();
                          }

                          final progress =
                              position.inMilliseconds /
                              duration.inMilliseconds;

                          return SliderTheme(
                            data: SliderTheme.of(state.context).copyWith(
                              activeTrackColor: Colors.red,
                              inactiveTrackColor: Colors.white.withOpacity(
                                0.3,
                              ),
                              thumbColor: Colors.red,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (value * duration.inMilliseconds)
                                          .round(),
                                );
                                state.widget.controller.player.seek(
                                  newPosition,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // 全屏按钮
                    IconButton(
                      onPressed: () {
                        // 这里可以添加全屏逻辑
                      },
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  // 显示设置对话框
  void _showSettingsDialog(BuildContext context, VideoController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('播放设置', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 播放速度设置
            ListTile(
              title: const Text('播放速度', style: TextStyle(color: Colors.white)),
              subtitle: StreamBuilder<double>(
                stream: controller.player.stream.rate,
                builder: (context, snapshot) {
                  final rate = snapshot.data ?? 1.0;
                  return Text(
                    '${rate}x',
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              trailing: const Icon(Icons.speed, color: Colors.white),
              onTap: () => _showSpeedDialog(context, controller),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 显示速度选择对话框
  void _showSpeedDialog(BuildContext context, VideoController controller) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('选择播放速度', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map(
                (speed) => ListTile(
                  title: Text(
                    '${speed}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    controller.player.setRate(speed);
                    Navigator.of(context).pop(); // 关闭设置对话框
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // 获取播放器实例（供外部使用）
  Player get playerInstance => player;

  // 获取控制器实例（供外部使用）
  VideoController get controllerInstance => controller;
}

/// 视频播放器页面
class VideoPage extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const VideoPage({Key? key, required this.videoUrl, this.title})
    : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.title != null
            ? Text(widget.title!, style: const TextStyle(color: Colors.white))
            : null,
      ),
      body: SafeArea(
        child: VideoPlayer(
          videoUrl: widget.videoUrl,
          title: widget.title,
          showControls: true, // 显示自定义控件
        ),
      ),
    );
  }
}
