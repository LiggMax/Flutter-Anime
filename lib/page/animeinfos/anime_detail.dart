import 'package:flutter/material.dart';
import 'package:flutter_app/modules/bangumi_data.dart';

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

              AnimeInfoSection(
                title: '基本信息',
                children: [
                  AnimeInfoRow(label: '原名', value: widget.bangumiItem.name),
                  AnimeInfoRow(label: '中文名', value: widget.bangumiItem.nameCn),
                  AnimeInfoRow(label: '类型', value: widget.bangumiItem.typeText),
                  AnimeInfoRow(
                    label: '总集数',
                    value: '${widget.bangumiItem.totalEpisodes}话',
                  ),
                  AnimeInfoRow(label: '放送日期', value: widget.bangumiItem.date),
                  AnimeInfoRow(label: '播放平台', value: widget.bangumiItem.platform),
                ],
              ),

              const SizedBox(height: 20),

              AnimeInfoSection(
                title: '评分信息',
                children: [
                  AnimeInfoRow(label: '评分', value: widget.bangumiItem.scoreText),
                  AnimeInfoRow(
                    label: '评价人数',
                    value: '${widget.bangumiItem.totalRatingCount}人',
                  ),
                  if (widget.bangumiItem.rating != null)
                    AnimeInfoRow(
                      label: '排名',
                      value: '第${widget.bangumiItem.rating!.rank}名',
                    ),
                ],
              ),

              const SizedBox(height: 20),

              if (widget.bangumiItem.collection != null) ...[
                AnimeInfoSection(
                  title: '收藏信息',
                  children: [
                    AnimeInfoRow(
                      label: '总收藏',
                      value: '${widget.bangumiItem.totalCollectionCount}人',
                    ),
                    AnimeInfoRow(
                      label: '想看',
                      value: '${widget.bangumiItem.collection!.wish}人',
                    ),
                    AnimeInfoRow(
                      label: '在看',
                      value: '${widget.bangumiItem.collection!.doing}人',
                    ),
                    AnimeInfoRow(
                      label: '看过',
                      value: '${widget.bangumiItem.collection!.collect}人',
                    ),
                    AnimeInfoRow(
                      label: '搁置',
                      value: '${widget.bangumiItem.collection!.onHold}人',
                    ),
                    AnimeInfoRow(
                      label: '抛弃',
                      value: '${widget.bangumiItem.collection!.dropped}人',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],

              if (widget.bangumiItem.mainTags.isNotEmpty) ...[
                AnimeInfoSection(
                  title: '标签',
                  children: [
                    AnimeTagsRow(tags: widget.bangumiItem.mainTags),
                  ],
                ),
              ],

              // 底部间距
              const SizedBox(height: 100),
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
        final tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
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

/// 信息区域组件
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
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
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

  const AnimeInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

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
class AnimeTagsRow extends StatelessWidget {
  final List<String> tags;

  const AnimeTagsRow({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withAlpha(52)),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
