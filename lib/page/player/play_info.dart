import 'package:flutter/material.dart';
import 'video/video_page.dart';
import 'comments.dart';
import 'details_info.dart';

class VideoInfoPage extends StatefulWidget {
  final int? animeId;
  final String? animeName;

  const VideoInfoPage({super.key, this.animeId, this.animeName});

  @override
  State<VideoInfoPage> createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  final GlobalKey<VideoPageState> _videoPageKey = GlobalKey<VideoPageState>();

  // 构建内容组件（详情和评论标签页）
  Widget _buildContentWidget() {
    return DefaultTabController(
      length: 2, // 两个标签页
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: '详情'),
              Tab(text: '评论'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DetailPage(
                  animeId: widget.animeId,
                  animeName: widget.animeName,
                  onVideoUrlReceived: _onVideoUrlReceived,
                  onStartParsing: _onStartParsing,
                ), // 详情页面
                CommentsPage(), // 评论页面
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 处理视频URL接收
  void _onVideoUrlReceived(String videoUrl) {
    if (_videoPageKey.currentState != null) {
      _videoPageKey.currentState!.playVideo(videoUrl);
    }
  }

  // 处理开始解析
  void _onStartParsing() {
    if (_videoPageKey.currentState != null) {
      _videoPageKey.currentState!.startParsingVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoPage(
      key: _videoPageKey,
      animeId: widget.animeId,
      animeName: widget.animeName,
      contentWidget: _buildContentWidget(),
    );
  }
}
