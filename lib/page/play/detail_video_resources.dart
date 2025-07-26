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
  Map<String, List<String>>? _videoSourceData;

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
                '解析到 ${_videoSourceData!['titles']?.length ?? 0} 个条目',
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
  final Map<String, List<String>> videoSourceData;
  final String animeName;

  const VideoSourceDrawer({
    super.key,
    required this.videoSourceData,
    required this.animeName,
  });

  @override
  Widget build(BuildContext context) {
    final titles = videoSourceData['titles'] ?? [];
    final links = videoSourceData['links'] ?? [];
    final itemCount = titles.length > links.length
        ? titles.length
        : links.length;

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
                      '视频源列表',
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
                      '共找到 $itemCount 个视频源',
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
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          final title = index < titles.length
                              ? titles[index]
                              : '未知标题';
                          final link = index < links.length ? links[index] : '';

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 16,
                            ),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: link.isNotEmpty
                                    ? Text(
                                        link,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: const Icon(
                                  Icons.play_circle_outline,
                                  color: Color(0xFF8B5CF6),
                                ),
                                onTap: () {
                                  // TODO: 处理视频源选择
                                  print('选择视频源: $title');
                                  print('链接: $link');
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '暂无视频源',
                              style: TextStyle(
                                fontSize: 16,
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
