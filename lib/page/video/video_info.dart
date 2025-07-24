import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 视频播放器 - 设置16:9比例，确保不覆盖状态栏
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Video(controller: controller),
            ),

          // 控件区域 - 放置在视频播放器下方
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 控制按钮
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => player.play(),
                          child: const Text('播放'),
                        ),
                        ElevatedButton(
                          onPressed: () => player.pause(),
                          child: const Text('暂停'),
                        ),
                        ElevatedButton(
                          onPressed: () => player.stop(),
                          child: const Text('停止'),
                        ),
                      ],
                    ),
                  ),

                  // 音量控制
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up),
                        Expanded(
                          child: StreamBuilder<double>(
                            stream: player.stream.volume,
                            builder: (context, snapshot) {
                              return Slider(
                                value: snapshot.data?.toDouble() ?? 100.0,
                                min: 0.0,
                                max: 100.0,
                                onChanged: (value) => player.setVolume(value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 进度条
                  StreamBuilder<Duration>(
                    stream: player.stream.position,
                    builder: (context, positionSnapshot) {
                      return StreamBuilder<Duration>(
                        stream: player.stream.duration,
                        builder: (context, durationSnapshot) {
                          final position = positionSnapshot.data ?? Duration.zero;
                          final duration = durationSnapshot.data ?? Duration.zero;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Slider(
                                  value: position.inMilliseconds.toDouble(),
                                  min: 0.0,
                                  max: duration.inMilliseconds.toDouble(),
                                  onChanged: (value) {
                                    player.seek(Duration(milliseconds: value.toInt()));
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatDuration(position)),
                                    Text(formatDuration(duration)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
