import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

// 顶部控制栏组件
class VideoTopControls extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const VideoTopControls({
    super.key,
    this.title,
    this.onBack,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onPressed: onBack,
          ),
          // 标题
          Expanded(
            child: Text(
              title ?? '视频标题',
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
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

// 底部控制栏组件
class VideoBottomControls extends StatelessWidget {
  final Player player;
  final bool isDragging;
  final Duration dragPosition;
  final VoidCallback? onPlayPause;
  final VoidCallback? onFullscreen;
  final Function(double)? onSeekStart;
  final Function(double)? onSeekChanged;
  final Function(double)? onSeekEnd;
  final VoidCallback? onInteraction;

  const VideoBottomControls({
    super.key,
    required this.player,
    required this.isDragging,
    required this.dragPosition,
    this.onPlayPause,
    this.onFullscreen,
    this.onSeekStart,
    this.onSeekChanged,
    this.onSeekEnd,
    this.onInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              final position = positionSnapshot.data ?? Duration.zero;
              final duration = durationSnapshot.data ?? Duration.zero;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 时间显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        formatDuration(
                          isDragging ? dragPosition : position,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(
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
                          final isPlaying = snapshot.data ?? false;
                          return IconButton(
                            iconSize: 35,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              onPlayPause?.call();
                              onInteraction?.call(); // 触发交互时显示控件
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
                                final buffer = bufferSnapshot.data ?? Duration.zero;
                                final bufferProgress = duration.inMilliseconds > 0
                                    ? (buffer.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                                    : 0.0;

                                return Container(
                                  height: 4.0,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 22.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.0),
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: bufferProgress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2.0),
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 主进度条
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.transparent,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withAlpha(76),
                                trackHeight: 4.0,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: isDragging ? 10.0 : 8.0,
                                ),
                              ),
                              child: Slider(
                                value: duration.inMilliseconds > 0
                                    ? (isDragging
                                        ? dragPosition.inMilliseconds.toDouble().clamp(
                                            0.0,
                                            duration.inMilliseconds.toDouble(),
                                          )
                                        : position.inMilliseconds.toDouble().clamp(
                                            0.0,
                                            duration.inMilliseconds.toDouble(),
                                          ))
                                    : 0.0,
                                min: 0.0,
                                max: duration.inMilliseconds > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1.0,
                                onChangeStart: duration.inMilliseconds > 0 ? onSeekStart : null,
                                onChanged: duration.inMilliseconds > 0 ? onSeekChanged : null,
                                onChangeEnd: duration.inMilliseconds > 0 ? onSeekEnd : null,
                              ),
                            ),

                            // 拖拽时显示时间预览
                            if (isDragging)
                              Positioned(
                                top: -35,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      formatDuration(dragPosition),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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
                        onPressed: onFullscreen,
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
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

// 综合的视频控件组件
class VideoPlayerControls extends StatelessWidget {
  final Player player;
  final bool showControls;
  final bool isDragging;
  final Duration dragPosition;
  final String? title;
  final VoidCallback? onTap;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final VoidCallback? onPlayPause;
  final VoidCallback? onFullscreen;
  final Function(double)? onSeekStart;
  final Function(double)? onSeekChanged;
  final Function(double)? onSeekEnd;

  const VideoPlayerControls({
    Key? key,
    required this.player,
    required this.showControls,
    required this.isDragging,
    required this.dragPosition,
    this.title,
    this.onTap,
    this.onBack,
    this.onSettings,
    this.onPlayPause,
    this.onFullscreen,
    this.onSeekStart,
    this.onSeekChanged,
    this.onSeekEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景点击区域 - 用于显示/隐藏控件
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // 顶部控制栏
        if (showControls)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {}, // 阻止事件穿透
              child: VideoTopControls(
                title: title,
                onBack: onBack,
                onSettings: onSettings,
              ),
            ),
          ),

        // 底部控制栏
        if (showControls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {}, // 阻止事件穿透
              child: VideoBottomControls(
                player: player,
                isDragging: isDragging,
                dragPosition: dragPosition,
                onPlayPause: onPlayPause,
                onFullscreen: onFullscreen,
                onSeekStart: onSeekStart,
                onSeekChanged: onSeekChanged,
                onSeekEnd: onSeekEnd,
              ),
            ),
          ),
      ],
    );
  }
}
