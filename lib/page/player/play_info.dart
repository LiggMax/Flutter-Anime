import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'video/video_page.dart';
import '../../request/video_service.dart';

class PlayInfo extends StatefulWidget {
  final String? title;
  final Map<String, dynamic>? videoInfo;

  const PlayInfo({Key? key, this.title, this.videoInfo}) : super(key: key);

  @override
  State<PlayInfo> createState() => _PlayInfoState();
}

class _PlayInfoState extends State<PlayInfo> {
  // 创建播放器实例（与 VideoPlayer 共享）
  late final player = Player();
  late final controller = VideoController(player);

  // 临时的视频URL常量
  static const String _tempVideoUrl =
      'https://apn.moedot.net/d/wo/2507/%E6%9B%B4%E8%A1%A304z.mp4';

  // 实际的视频URL
  String? _actualVideoUrl;
  bool _isLoadingVideo = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // 使用临时的视频URL
      _actualVideoUrl = _tempVideoUrl;
      await _loadVideo();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频加载失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadVideo() async {
    if (_actualVideoUrl == null) return;

    try {
      final media = Media(_actualVideoUrl!);
      await player.open(media);
      await player.setPlaylistMode(PlaylistMode.single);
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
        title: Text(
          widget.title ?? '播放信息',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: Colors.white),
            onPressed: () {
              // 导航到视频播放页面
              if (_actualVideoUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPage(
                      videoUrl: _actualVideoUrl!,
                      title: widget.title,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('视频还未加载完成'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 视频预览区域
            Container(
              height: 200,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isLoadingVideo
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _actualVideoUrl != null
                    ? VideoPlayer(
                        videoUrl: _actualVideoUrl!,
                        showControls: false, // 不显示控件，仅预览
                      )
                    : const Center(
                        child: Text(
                          '视频加载失败',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),

            // 播放信息区域
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // 播放状态信息
                      _buildPlaybackInfo(),

                      const SizedBox(height: 24),

                      // 视频信息
                      if (widget.videoInfo != null) _buildVideoInfo(),

                      const SizedBox(height: 24),

                      // 控制选项
                      _buildControlOptions(),

                      const SizedBox(height: 24),

                      // 播放按钮
                      _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '播放状态',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 播放状态
          StreamBuilder<bool>(
            stream: player.stream.playing,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return Row(
                children: [
                  Icon(
                    isPlaying
                        ? Icons.play_circle_filled
                        : Icons.pause_circle_filled,
                    color: isPlaying ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPlaying ? '正在播放' : '已暂停',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // 播放进度
          StreamBuilder<Duration>(
            stream: player.stream.position,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = player.state.duration;

              if (duration.inSeconds == 0) {
                return const Text(
                  '加载中...',
                  style: TextStyle(color: Colors.grey),
                );
              }

              final progress =
                  position.inMilliseconds / duration.inMilliseconds;

              return Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[700],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // 音量信息
          StreamBuilder<double>(
            stream: player.stream.volume,
            builder: (context, snapshot) {
              final volume = snapshot.data ?? 100.0;
              return Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '音量: ${volume.round()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '视频信息',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 视频参数信息
          StreamBuilder<VideoParams>(
            stream: player.stream.videoParams,
            builder: (context, snapshot) {
              final videoParams = snapshot.data;
              if (videoParams == null) {
                return const Text(
                  '加载视频信息中...',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                children: [
                  if (widget.videoInfo != null) ...[
                    if (widget.videoInfo!['duration'] != null)
                      _buildInfoRow('时长', widget.videoInfo!['duration']),
                    if (widget.videoInfo!['quality'] != null)
                      _buildInfoRow('画质', widget.videoInfo!['quality']),
                    if (widget.videoInfo!['size'] != null)
                      _buildInfoRow('大小', widget.videoInfo!['size']),
                    if (widget.videoInfo!['animeId'] != null)
                      _buildInfoRow(
                        '动漫ID',
                        widget.videoInfo!['animeId'].toString(),
                      ),
                    if (widget.videoInfo!['animeName'] != null)
                      _buildInfoRow('动漫名称', widget.videoInfo!['animeName']),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildControlOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '播放控制',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 播放/暂停
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

              // 停止
              IconButton(
                onPressed: () => player.stop(),
                icon: const Icon(Icons.stop, color: Colors.white, size: 32),
              ),

              // 音量控制
              StreamBuilder<double>(
                stream: player.stream.volume,
                builder: (context, snapshot) {
                  final volume = snapshot.data ?? 100.0;
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          final newVolume = volume > 0 ? 0.0 : 100.0;
                          player.setVolume(newVolume);
                        },
                        icon: Icon(
                          volume > 0 ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Text(
                        '${volume.round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 设置
              IconButton(
                onPressed: () {
                  _showSettingsDialog();
                },
                icon: const Icon(Icons.settings, color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (_actualVideoUrl != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPage(videoUrl: _actualVideoUrl!, title: widget.title),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('视频还未加载完成'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white),
            SizedBox(width: 8),
            Text(
              '开始播放',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
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
                stream: player.stream.rate,
                builder: (context, snapshot) {
                  final rate = snapshot.data ?? 1.0;
                  return Text(
                    '${rate}x',
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              trailing: const Icon(Icons.speed, color: Colors.white),
              onTap: () => _showSpeedDialog(),
            ),

            // 循环模式设置
            ListTile(
              title: const Text('循环模式', style: TextStyle(color: Colors.white)),
              subtitle: StreamBuilder<PlaylistMode>(
                stream: player.stream.playlistMode,
                builder: (context, snapshot) {
                  final mode = snapshot.data ?? PlaylistMode.none;
                  String modeText = '不循环';
                  switch (mode) {
                    case PlaylistMode.single:
                      modeText = '单曲循环';
                      break;
                    case PlaylistMode.loop:
                      modeText = '列表循环';
                      break;
                    default:
                      modeText = '不循环';
                  }
                  return Text(
                    modeText,
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              trailing: const Icon(Icons.repeat, color: Colors.white),
              onTap: () => _showLoopModeDialog(),
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

  void _showSpeedDialog() {
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
                    player.setRate(speed);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLoopModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('选择循环模式', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('不循环', style: TextStyle(color: Colors.white)),
              onTap: () {
                player.setPlaylistMode(PlaylistMode.none);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('单曲循环', style: TextStyle(color: Colors.white)),
              onTap: () {
                player.setPlaylistMode(PlaylistMode.single);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('列表循环', style: TextStyle(color: Colors.white)),
              onTap: () {
                player.setPlaylistMode(PlaylistMode.loop);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

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
