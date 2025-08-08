/*
  @Author Ligg
  @Time 2025/8/8
 */
import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';

class Collection extends StatefulWidget {
  const Collection({super.key, required this.userInfo});

  final UserInfo userInfo;

  @override
  State<StatefulWidget> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> tabs = widget.userInfo.collectionItems
        .map((e) => e['label'] as String)
        .toList();

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部标签栏（M3 风格）
          Padding(
            padding: EdgeInsets.zero,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              dividerColor: colorScheme.surfaceContainerHighest,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 16),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 由于外层是 SingleChildScrollView，这里需要给定确定高度
          // 先提供一个合适的高度占位，后续内容页实现后可改为自适应
          SizedBox(
            height: 500,
            child: TabBarView(
              // 水平滑动切换
              children: tabs
                  .map(
                    (t) => Center(
                      child: Text(
                        '$t – 开发中…',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
