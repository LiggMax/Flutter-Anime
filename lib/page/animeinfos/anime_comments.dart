import 'package:flutter/material.dart';

/// 评论内容组件
class AnimeCommentsContent extends StatelessWidget {
  const AnimeCommentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              '施工中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '评论功能正在开发中',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 评论列表组件 (预留)
class AnimeCommentsList extends StatelessWidget {
  const AnimeCommentsList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 实现评论列表
    return const AnimeCommentsContent();
  }
}

/// 评论输入框组件 (预留)
class AnimeCommentsInput extends StatefulWidget {
  final VoidCallback? onSubmit;

  const AnimeCommentsInput({
    super.key,
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
    return const SizedBox.shrink();
  }
}
