import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPage extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const VideoPage({Key? key, required this.videoUrl, this.title})
    : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  // 创建播放器实例
  late final player = Player();
  // 创建视频控制器
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // 打开视频
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
    // 重要：释放播放器资源
    player.dispose();
    super.dispose();
  }

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
        child: Column(
          children: [
            // 视频播放区域
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Video(
                    controller: controller,
                    // 使用 Material Design 控件
                    controls: MaterialVideoControls,
                  ),
                ),
              ),
            ),

            // 自定义控制按钮区域
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 播放/暂停按钮
                  StreamBuilder<bool>(
                    stream: player.stream.playing,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return IconButton(
                        onPressed: () => player.playOrPause(),
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),

                  // 后退 10 秒
                  IconButton(
                    onPressed: () async {
                      final position = player.state.position;
                      final newPosition =
                          position - const Duration(seconds: 10);
                      if (newPosition.inSeconds >= 0) {
                        await player.seek(newPosition);
                      }
                    },
                    icon: const Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // 前进 10 秒
                  IconButton(
                    onPressed: () async {
                      final position = player.state.position;
                      final duration = player.state.duration;
                      final newPosition =
                          position + const Duration(seconds: 10);
                      if (newPosition < duration) {
                        await player.seek(newPosition);
                      }
                    },
                    icon: const Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // 全屏按钮
                  IconButton(
                    onPressed: () {
                      // 这里可以添加全屏逻辑
                      debugPrint('全屏功能');
                    },
                    icon: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // 进度条
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: StreamBuilder<Duration>(
                stream: player.stream.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = player.state.duration;

                  if (duration.inSeconds == 0) {
                    return const SizedBox.shrink();
                  }

                  final progress =
                      position.inMilliseconds / duration.inMilliseconds;

                  return Column(
                    children: [
                      // 进度条
                      Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds: (value * duration.inMilliseconds)
                                .round(),
                          );
                          player.seek(newPosition);
                        },
                        activeColor: Colors.red,
                        inactiveColor: Colors.grey[600],
                      ),

                      // 时间显示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 格式化时间显示
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
