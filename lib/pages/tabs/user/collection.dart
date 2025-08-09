/*
  @Author Ligg
  @Time 2025/8/8
 */
import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:AnimeFlow/modules/bangumi/user_collection.dart';

class Collection extends StatelessWidget {
  const Collection({
    super.key,
    required this.userInfo,
    required this.collections,
    required this.currentType,
  });

  final UserInfo userInfo;
  final Map<int, UserCollection> collections;
  final int currentType; // 当前选中的类型 id

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items =
        collections[currentType]?.data ?? const <UserCollectionItem>[];

    if (items.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final it = items[index];
        final s = it.subject;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                s.images.small.isNotEmpty ? s.images.small : s.images.grid,
                width: 48,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 64,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            title: Text(
              s.nameCN?.isNotEmpty == true ? s.nameCN! : s.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              s.date ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (s.score != null)
                  Text(
                    s.score!.toStringAsFixed(1),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (it.epStatus > 0)
                  Text(
                    'Ep ${it.epStatus}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
