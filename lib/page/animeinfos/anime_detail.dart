import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi_data.dart';

/// 详情内容主组件
class AnimeDetailContent extends StatefulWidget {
  final BangumiDetailData bangumiItem;
  final double maxWidth;

  const AnimeDetailContent({
    super.key,
    required this.bangumiItem,
    required this.maxWidth,
  });

  @override
  State<AnimeDetailContent> createState() => _AnimeDetailContentState();
}

class _AnimeDetailContentState extends State<AnimeDetailContent> {
  bool summaryExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width > widget.maxWidth
              ? widget.maxWidth
              : MediaQuery.sizeOf(context).width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.bangumiItem.summary.isNotEmpty) ...[
                AnimeInfoSection(
                  title: '简介',
                  children: [
                    AnimeExpandableSummary(
                      summary: widget.bangumiItem.summary,
                      isExpanded: summaryExpanded,
                      onToggle: () {
                        setState(() {
                          summaryExpanded = !summaryExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ],

              if (widget.bangumiItem.mainTags.isNotEmpty) ...[
                AnimeInfoSection(
                  title: '标签',
                  children: [AnimeTagsRow(tags: widget.bangumiItem.mainTags)],
                ),
              ],

              if (widget.bangumiItem.tags.isNotEmpty) ...[
                AnimeInfoSection(
                  title: '基本信息',
                  children: [
                    AnimeInfoRow(label: '原名', value: widget.bangumiItem.name),
                    AnimeInfoRow(
                      label: '中文名',
                      value: widget.bangumiItem.nameCn,
                    ),
                    AnimeInfoRow(
                      label: '类型',
                      value: widget.bangumiItem.typeText,
                    ),
                    AnimeInfoRow(
                      label: '总集数',
                      value: '${widget.bangumiItem.totalEpisodes}话',
                    ),
                    AnimeInfoRow(label: '放送日期', value: widget.bangumiItem.date),
                    AnimeInfoRow(
                      label: '播放平台',
                      value: widget.bangumiItem.platform,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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

/// 简介组件
class AnimeInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AnimeInfoSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// 信息行组件
class AnimeInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const AnimeInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签行组件
class AnimeTagsRow extends StatefulWidget {
  final List<BangumiTag> tags;
  final int maxInitialTags; // 默认显示的标签数量

  const AnimeTagsRow({
    super.key,
    required this.tags,
    this.maxInitialTags = 6, // 默认显示6个标签
  });

  @override
  State<AnimeTagsRow> createState() => _AnimeTagsRowState();
}

class _AnimeTagsRowState extends State<AnimeTagsRow> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 判断是否需要展开功能
    final bool needsExpansion = widget.tags.length > widget.maxInitialTags;
    final List<BangumiTag> tagsToShow = needsExpansion && !isExpanded
        ? widget.tags.take(widget.maxInitialTags).toList()
        : widget.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: tagsToShow
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withAlpha(52)),
                  ),
                  child: Text(
                    '${tag.name} (${tag.count})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // 展开/收起按钮
        if (needsExpansion) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded
                        ? '收起 (${widget.tags.length - widget.maxInitialTags})'
                        : '展开 (+${widget.tags.length - widget.maxInitialTags})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
