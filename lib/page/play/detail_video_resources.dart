/*
  @Author Ligg
  @Time 2025/7/26
 */

///视频源组件
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/video.dart';

class PlayData extends StatelessWidget {
  const PlayData({Key? key}) : super(key: key);

  Future<void> getVideoSource(String keyword, int ep) async {
    final response = await VideoService.getVideoSource(keyword, ep);
    if (response != null) {
      // 处理数据
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Text('视频源组件'),
    );
  }
}
