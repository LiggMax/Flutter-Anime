/*
  @Author Ligg
  @Time 2025/7/26
 */

///视频源组件
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/video.dart';
import 'package:AnimeFlow/modules/episodes_data.dart';

class PlayData extends StatelessWidget {
  final Episode? selectedEpisode;
  final String? animeName;

  const PlayData({
    Key? key,
    this.selectedEpisode,
    this.animeName,
  }) : super(key: key);

  Future<void> getVideoSource(String keyword, int ep) async {
    final response = await VideoService.getVideoSource(keyword, ep);
    if (response != null) {
      print('获取到视频源: $response');
      // 处理数据
    }
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
              if (selectedEpisode != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    if (animeName != null) {
                      await getVideoSource(animeName!, selectedEpisode!.ep);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6), // 紫色背景
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF8B5CF6).withAlpha(53),
                    minimumSize: Size.zero,
                  ),
                  icon: const Icon(
                    Icons.repeat_rounded,
                    size: 20,
                  ),
                  label: const Text(
                    '获取视频源',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (selectedEpisode != null) ...[
            Text(
              '当前选中: ${selectedEpisode!.nameCn.isNotEmpty ? selectedEpisode!.nameCn : selectedEpisode!.name} - 第${selectedEpisode!.ep}集',
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ] else ...[
            const Text(
              '请选择剧集',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
