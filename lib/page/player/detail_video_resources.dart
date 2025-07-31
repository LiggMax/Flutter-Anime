/*
  @Author Ligg
  @Time 2025/7/26
 */

///视频源组件
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/video_service.dart';
import 'package:AnimeFlow/modules/episodes_data.dart';

class PlayData extends StatefulWidget {
  final Episode? selectedEpisode;
  final String? animeName;
  final Function(String)? onVideoUrlReceived;
  final VoidCallback? onStartParsing;

  const PlayData({
    super.key, 
    this.selectedEpisode, 
    this.animeName,
    this.onVideoUrlReceived,
    this.onStartParsing,
  });

  @override
  State<PlayData> createState() => _PlayDataState();
}

class _PlayDataState extends State<PlayData> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _videoSourceData;

  @override
  void initState() {
    super.initState();
    // 组件加载时自动调用获取视频源
    if (widget.selectedEpisode != null && widget.animeName != null) {
      _getVideoSource();
    }
  }

  @override
  void didUpdateWidget(PlayData oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当选中的剧集发生变化时，重新获取视频源
    if (widget.selectedEpisode != oldWidget.selectedEpisode &&
        widget.selectedEpisode != null &&
        widget.animeName != null) {
      _getVideoSource();
    }
  }

  Future<void> _getVideoSource() async {
    if (widget.animeName == null || widget.selectedEpisode == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await VideoService.getVideoSource(
        widget.animeName!,
        widget.selectedEpisode!.ep,
      );

      setState(() {
        _videoSourceData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('获取视频源失败: $e');
    }
  }

  //获取视频url
  Future<void> _getVideoUrl(String sourceUrl) async {
    try {
      // 通知开始解析
      widget.onStartParsing?.call();
      
      final videoUrl = await VideoService.getPlayUrl(sourceUrl);
      if (videoUrl != null) {
        // 回调videoUrl给父组件处理
        widget.onVideoUrlReceived?.call(videoUrl);
      }
    } catch (e) {
      print('获取播放地址失败: $e');
    }
  }

  void _showVideoSourceDrawer() {
    if (_videoSourceData == null) {
      // 如果没有数据，先获取数据
      _getVideoSource();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return VideoSourceDrawer(
          videoSourceData: _videoSourceData!,
          animeName: widget.animeName ?? '',
          onEpisodeSelected: _getVideoUrl,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '视频源',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.selectedEpisode != null)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _showVideoSourceDrawer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    // 紫色背景
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF8B5CF6).withAlpha(53),
                    minimumSize: Size.zero,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.repeat_rounded, size: 20),
                  label: Text(
                    _isLoading ? '获取中...' : '更换资源',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.selectedEpisode != null) ...[
            Text(
              '当前选中: ${widget.selectedEpisode!.nameCn.isNotEmpty ? widget.selectedEpisode!.nameCn : widget.selectedEpisode!.name} - 第${widget.selectedEpisode!.ep}集',
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '正在获取视频源...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ] else ...[
            const Text('请选择剧集', style: TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

/// 视频源抽屉弹窗组件
class VideoSourceDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> videoSourceData;
  final String animeName;
  final Function(String) onEpisodeSelected;

  const VideoSourceDrawer({
    super.key,
    required this.videoSourceData,
    required this.animeName,
    required this.onEpisodeSelected,
  });

  // 计算剧集卡片总数量
  int _calculateTotalItems() {
    int total = 0;
    for (final episodeData in videoSourceData) {
      final routes = episodeData['routes'] as List<Map<String, String>>? ?? [];
      final episodes =
          episodeData['episodes'] as List<List<Map<String, String>>>? ?? [];

      for (int i = 0; i < routes.length && i < episodes.length; i++) {
        total += episodes[i].length; // 每个剧集一张卡片
      }
    }
    return total;
  }

  // 构建剧集卡片
  Widget _buildEpisodeCard(BuildContext context, int index) {
    int currentIndex = 0;

    for (
      int sourceIndex = 0;
      sourceIndex < videoSourceData.length;
      sourceIndex++
    ) {
      final episodeData = videoSourceData[sourceIndex];
      final title = episodeData['title'] ?? '未知标题';
      final routes = episodeData['routes'] as List<Map<String, String>>? ?? [];
      final episodes =
          episodeData['episodes'] as List<List<Map<String, String>>>? ?? [];

      for (
        int routeIndex = 0;
        routeIndex < routes.length && routeIndex < episodes.length;
        routeIndex++
      ) {
        final route = routes[routeIndex];
        final routeEpisodes = episodes[routeIndex];

        for (
          int episodeIndex = 0;
          episodeIndex < routeEpisodes.length;
          episodeIndex++
        ) {
          if (currentIndex == index) {
            final episode = routeEpisodes[episodeIndex];
            return _buildSingleEpisodeCard(
              context,
              title,
              route,
              episode,
              episodeIndex,
              onEpisodeSelected, // 传递回调函数
            );
          }
          currentIndex++;
        }
      }
    }

    return const SizedBox.shrink();
  }

  // 构建单个剧集卡片
  Widget _buildSingleEpisodeCard(
    BuildContext context,
    String sourceTitle,
    Map<String, String> route,
    Map<String, String> episode,
    int episodeIndex,
    Function(String) onEpisodeSelected,
  ) {
    final routeName = route['name'] ?? route['original'] ?? '未知线路';
    final episodeTitle = episode['title'] ?? '未知剧集';
    final episodeNumber = episode['episode'] ?? '${episodeIndex + 1}';
    final episodeUrl = episode['url'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            print('选择剧集: $episodeTitle');
            print('剧集序号: $episodeNumber');
            print('剧集URL: $episodeUrl');
            print('线路: $routeName');
            print('条目: $sourceTitle');
            // 调用回调函数，传递episodeUrl
            onEpisodeSelected(episodeUrl);
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 剧集信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 剧集标题和episodeTitle
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sourceTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            episodeTitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // 线路标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          routeName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = videoSourceData.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.all(10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // 标题栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择视频资源',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '筛选了 ${_calculateTotalItems()} 条资源',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // 视频源列表
              Expanded(
                child: itemCount > 0
                    ? ListView.builder(
                        controller: scrollController,
                        itemCount: _calculateTotalItems(),
                        itemBuilder: (context, index) {
                          return _buildEpisodeCard(context, index);
                        },
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '暂无剧集数据',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '请尝试重新获取或检查网络连接',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
