import 'package:flutter/material.dart';
import 'detail_info.dart';

/// 简介组件
class AnimeSummarySection extends StatefulWidget {
  final String summary;

  const AnimeSummarySection({
    super.key,
    required this.summary,
  });

  @override
  State<AnimeSummarySection> createState() => _AnimeSummarySectionState();
}

class _AnimeSummarySectionState extends State<AnimeSummarySection> {
  bool summaryExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.summary.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimeInfoSection(
      title: '简介',
      children: [
        AnimeExpandableSummary(
          summary: widget.summary,
          isExpanded: summaryExpanded,
          onToggle: () {
            setState(() {
              summaryExpanded = !summaryExpanded;
            });
          },
        ),
      ],
    );
  }
}

/// 可展开的简介组件
class AnimeExpandableSummary extends StatelessWidget {
  final String summary;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AnimeExpandableSummary({
    super.key,
    required this.summary,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) {
      return const Text(
        '暂无简介',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    }

    // 处理换行符和格式化文本
    final formattedSummary = summary
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\n', '\n')
        .trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: formattedSummary,
          style: const TextStyle(fontSize: 14, height: 1.5),
        );
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: constraints.maxWidth);
        final numLines = tp.computeLineMetrics().length;

        // 如果总行数 <= 5行，直接显示全部内容
        if (numLines <= 5) {
          return Text(
            formattedSummary,
            style: const TextStyle(fontSize: 14, height: 1.5),
          );
        }

        // 超过5行，实现展开/收起功能
        return GestureDetector(
          onTap: onToggle,
          child: Text(
            formattedSummary,
            style: const TextStyle(fontSize: 14, height: 1.5),
            maxLines: isExpanded ? null : 5,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
} 