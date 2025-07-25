import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

// 顶部控制栏组件
class VideoTopControls extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final bool isFullscreen;

  const VideoTopControls({
    super.key, 
    this.title, 
    this.onBack, 
    this.onSettings,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromRGBO(0, 0, 0, 0.3), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: Icon(
              isFullscreen ? Icons.fullscreen_exit : Icons.arrow_back_ios,
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
            icon: const Icon(Icons.settings, color: Colors.white),
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
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Duration buffer;
  final bool isFullscreen;
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
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.buffer,
    required this.isFullscreen,
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color.fromRGBO(0, 0, 0, 0.4), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 时间显示
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                formatDuration(isDragging ? dragPosition : position),
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
              IconButton(
                iconSize: 35,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  onPlayPause?.call();
                  onInteraction?.call(); // 触发交互时显示控件
                },
              ),

              // 进度条区域
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(),
                  child: Stack(
                    children: [
                      // 缓冲进度条背景
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white.withAlpha(10),
                          // 缓冲进度颜色
                          inactiveTrackColor: Colors.white.withAlpha(10),
                          // 背景颜色
                          thumbColor: Colors.white,
                          // 隐藏滑块
                          overlayColor: Colors.transparent,
                          // 隐藏覆盖层
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 0,
                          ), // 隐藏滑块
                        ),
                        child: Slider(
                          value: duration.inMilliseconds > 0
                              ? buffer.inMilliseconds.toDouble().clamp(
                                  0.0,
                                  duration.inMilliseconds.toDouble(),
                                )
                              : 0.0,
                          min: 0.0,
                          max: duration.inMilliseconds > 0
                              ? duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: null, // 禁用交互
                        ),
                      ),

                      // 主进度条
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withAlpha(53),
                          trackHeight: 4.0,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: isDragging ? 10.0 : 8.0,
                          ),
                        ),
                        child: Slider(
                          value: duration.inMilliseconds > 0
                              ? (isDragging
                                    ? dragPosition.inMilliseconds
                                          .toDouble()
                                          .clamp(
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
                          onChangeStart: duration.inMilliseconds > 0
                              ? onSeekStart
                              : null,
                          onChanged: duration.inMilliseconds > 0
                              ? onSeekChanged
                              : null,
                          onChangeEnd: duration.inMilliseconds > 0
                              ? onSeekEnd
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 全屏按钮
              IconButton(
                iconSize: 35,
                icon: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: onFullscreen,
              ),
            ],
          ),
        ],
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
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Duration buffer;
  final bool isFullscreen;
  final VoidCallback? onTap;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final VoidCallback? onPlayPause;
  final VoidCallback? onFullscreen;
  final Function(double)? onSeekStart;
  final Function(double)? onSeekChanged;
  final Function(double)? onSeekEnd;

  const VideoPlayerControls({
    super.key,
    required this.player,
    required this.showControls,
    required this.isDragging,
    required this.dragPosition,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.buffer,
    required this.isFullscreen,
    this.title,
    this.onTap,
    this.onBack,
    this.onSettings,
    this.onPlayPause,
    this.onFullscreen,
    this.onSeekStart,
    this.onSeekChanged,
    this.onSeekEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景点击区域 - 用于显示/隐藏控件
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
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
                isFullscreen: isFullscreen,
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
                isPlaying: isPlaying,
                position: position,
                duration: duration,
                buffer: buffer,
                isFullscreen: isFullscreen,
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
