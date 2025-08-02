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
    Key? key,
    required this.videoUrl,
    this.title,
    this.onBackPressed,
    this.showControls = true,
  }) : super(key: key);

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
    // 重要：释放播放器资源
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Video(
        controller: controller,
        // 根据参数决定是否显示控件
        controls: widget.showControls ? MaterialVideoControls : NoVideoControls,
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
          showControls: true,
        ),
      ),
    );
  }
}
