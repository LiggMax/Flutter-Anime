/*
  @Author Ligg
  @Time 2025/8/8
 */
import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_collection.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';

class Collection extends StatefulWidget {
  const Collection({super.key, required this.userInfo, required this.token});

  final UserInfo userInfo;
  final BangumiToken token;

  @override
  State<StatefulWidget> createState() => _CollectionState();
}

class _CollectionState extends State<Collection>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _items;
  late final List<String> _tabs;
  late final TabController _tabController;

  final Map<int, UserCollection?> _cache = {}; // type -> data
  UserCollection? _currentCollection;
  bool _isLoading = false;
  String? _error;
  int? _inFlightType;

  @override
  void initState() {
    super.initState();
    _items = widget.userInfo.collectionItems;
    _tabs = _items.map((e) => e['label'] as String).toList();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // 首次进入拉取默认标签数据
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _getUserCollection(type: _items[0]['id'] as int),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final int type = _items[_tabController.index]['id'] as int;
      _getUserCollection(type: type);
    }
  }

  // 获取用户收藏（带缓存与并发保护）
  Future<void> _getUserCollection({required int type}) async {
    if (_cache.containsKey(type)) {
      setState(() {
        _currentCollection = _cache[type];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    if (_inFlightType == type) return;
    _inFlightType = type;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await BangumiUser.getUserCollection(
        widget.token,
        type,
        offset: 0,
      );
      _cache[type] = result;
      if (!mounted) return;
      setState(() {
        _currentCollection = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    } finally {
      _inFlightType = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部标签栏
        Padding(
          padding: EdgeInsets.zero,
          child: TabBar(
            controller: _tabController,
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
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
            onTap: (index) {
              final int type = _items[index]['id'] as int;
              _getUserCollection(type: type);
            },
          ),
        ),
        const SizedBox(height: 12),

        // 内容区：ListView 渲染（先显示加载/错误/空占位）
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((t) {
              if (_isLoading && _currentCollection == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null) {
                return Center(
                  child: Text(
                    '加载失败: $_error',
                    style: TextStyle(color: colorScheme.error),
                  ),
                );
              }
              final items =
                  _currentCollection?.data ?? const <UserCollectionItem>[];
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    '暂无数据',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return ListView.separated(
                itemCount: items.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final it = items[index];
                  final s = it.subject;
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          s.images.small.isNotEmpty
                              ? s.images.small
                              : s.images.grid,
                          width: 48,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 64,
                            color: Theme.of(context).colorScheme.surfaceVariant,
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
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
