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

  const PlayData({Key? key, this.selectedEpisode, this.animeName})
    : super(key: key);

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
            ] else if (_videoSourceData != null) ...[
              const SizedBox(height: 10),
              Text(
                '解析到 ${_videoSourceData!.length} 个条目',
                style: const TextStyle(fontSize: 12, color: Colors.green),
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

  const VideoSourceDrawer({
    super.key,
    required this.videoSourceData,
    required this.animeName,
  });

  // 计算展开后的总项目数
  int _calculateTotalItems() {
    int total = 0;
    for (final episodeData in videoSourceData) {
      total += 1; // 条目标题
      final routes = episodeData['routes'] as List<Map<String, String>>? ?? [];
      final episodes =
          episodeData['episodes'] as List<List<Map<String, String>>>? ?? [];

      for (int i = 0; i < routes.length && i < episodes.length; i++) {
        total += 1; // 线路标题
        total += episodes[i].length; // 该线路的剧集数量
      }
    }
    return total;
  }

  // 计算总剧集数
  int _getTotalEpisodeCount() {
    int total = 0;
    for (final episodeData in videoSourceData) {
      final episodes =
          episodeData['episodes'] as List<List<Map<String, String>>>? ?? [];
      for (final episodeList in episodes) {
        total += episodeList.length;
      }
    }
    return total;
  }

  // 构建列表项
  Widget _buildListItem(BuildContext context, int index) {
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

      // 条目标题
      if (currentIndex == index) {
        return _buildSourceTitle(title, sourceIndex);
      }
      currentIndex++;

      // 遍历线路和剧集
      for (
        int routeIndex = 0;
        routeIndex < routes.length && routeIndex < episodes.length;
        routeIndex++
      ) {
        final route = routes[routeIndex];
        final routeEpisodes = episodes[routeIndex];

        // 线路标题
        if (currentIndex == index) {
          return _buildRouteTitle(route, routeIndex);
        }
        currentIndex++;

        // 该线路的剧集
        for (
          int episodeIndex = 0;
          episodeIndex < routeEpisodes.length;
          episodeIndex++
        ) {
          if (currentIndex == index) {
            return _buildEpisodeItem(
              context,
              routeEpisodes[episodeIndex],
              episodeIndex,
            );
          }
          currentIndex++;
        }
      }
    }

    return const SizedBox.shrink();
  }

  // 构建条目标题
  Widget _buildSourceTitle(String title, int sourceIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: const Color(0xFF8B5CF6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${sourceIndex + 1}',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建线路标题
  Widget _buildRouteTitle(Map<String, String> route, int routeIndex) {
    final routeName = route['name'] ?? route['original'] ?? '未知线路';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Card(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.video_library, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                routeName,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建剧集项
  Widget _buildEpisodeItem(
    BuildContext context,
    Map<String, String> episode,
    int episodeIndex,
  ) {
    final episodeTitle = episode['title'] ?? '未知剧集';
    final episodeUrl = episode['url'] ?? '';
    final episodeNumber = episode['episode'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
      child: Card(
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 16,
            child: Text(
              episodeNumber.isNotEmpty ? episodeNumber : '${episodeIndex + 1}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            episodeTitle,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(
            Icons.play_arrow,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
          onTap: () {
            print('选择剧集: $episodeTitle');
            print('剧集URL: $episodeUrl');
            print('剧集序号: $episodeNumber');
            Navigator.of(context).pop();
          },
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
                    const Text(
                      '剧集条目列表',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      animeName,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '共找到 $itemCount 个条目 · ${_getTotalEpisodeCount()} 集剧集',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 视频源列表
              Expanded(
                child: itemCount > 0
                    ? ListView.builder(
                        controller: scrollController,
                        itemCount: _calculateTotalItems(),
                        itemBuilder: (context, index) {
                          return _buildListItem(context, index);
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
