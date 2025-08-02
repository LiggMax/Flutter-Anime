import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi.dart';
import 'package:AnimeFlow/modules/bangumi_comments.dart';

/// 评论内容组件
class AnimeCommentsContent extends StatefulWidget {
  final int animeId;

  const AnimeCommentsContent({super.key, required this.animeId});

  @override
  State<AnimeCommentsContent> createState() => _AnimeCommentsContentState();
}

class _AnimeCommentsContentState extends State<AnimeCommentsContent> {
  late Future<BangumiCommentsData?> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = BangumiService.getComments(widget.animeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BangumiCommentsData?>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  '加载评论失败',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: _loadComments,
                  child: const Text('重新加载'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // 成功获取数据，显示评论列表
          return AnimeCommentsList(
            animeId: widget.animeId,
            commentsData: snapshot.data!,
          );
        } else {
          // 没有数据
          return const Center(
            child: Text('暂无评论数据'),
          );
        }
      },
    );
  }
}

/// 评论列表组件
class AnimeCommentsList extends StatelessWidget {
  final int animeId;
  final BangumiCommentsData commentsData;

  const AnimeCommentsList({
    super.key,
    required this.animeId,
    required this.commentsData,
  });

  @override
  Widget build(BuildContext context) {
    if (commentsData.data.isEmpty) {
      return const Center(child: Text('暂无评论'));
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '评论 (${commentsData.total})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (commentsData.data.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('暂无评论'),
              ),
            )
          ] else ...[
            // 使用列布局渲染评论列表
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentsData.data.length,
              itemBuilder: (context, index) {
                final comment = commentsData.data[index];
                return _buildCommentItem(comment);
              },
            ),
          ]
        ],
      ),
    );
  }
  
  /// 构建单个评论项
  Widget _buildCommentItem(BangumiComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Row(
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(comment.user.avatar.defaultAvatar),
                  onBackgroundImageError: (exception, stackTrace) {
                    // 处理图片加载错误
                  },
                ),
                const SizedBox(width: 10),
                // 用户名称和信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${comment.user.groupText} | ${comment.updateTimeText}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // 评分信息
                if (comment.rate > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: comment.rate >= 8 
                          ? Colors.green 
                          : comment.rate >= 5 
                              ? Colors.orange 
                              : Colors.red,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      comment.rateText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // 评论内容
            if (comment.comment.isNotEmpty) ...[
              Text(
                comment.comment,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
            // 评论类型标签
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                comment.typeText,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 评论输入框组件 (预留)
class AnimeCommentsInput extends StatefulWidget {
  final int animeId;
  final VoidCallback? onSubmit;

  const AnimeCommentsInput({
    super.key,
    required this.animeId,
    this.onSubmit,
  });

  @override
  State<AnimeCommentsInput> createState() => _AnimeCommentsInputState();
}

class _AnimeCommentsInputState extends State<AnimeCommentsInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 实现评论输入框
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '输入你的评论...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现提交评论功能
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}
