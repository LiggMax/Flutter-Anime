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

  final Map<int, UserCollection?> _cache = {};
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
    // 命中缓存
    if (_cache.containsKey(type)) {
      setState(() {
        _currentCollection = _cache[type];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    // 避免重复请求同一类型
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
              // 立即根据点击的标签触发拉取（与滚动监听互补）
              final int type = _items[index]['id'] as int;
              _getUserCollection(type: type);
            },
          ),
        ),
        const SizedBox(height: 12),

        // 占位内容（后续替换为实际列表），展示加载/错误/结果概要
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
              final total = _currentCollection?.total;
              return Center(
                child: Text(
                  total == null ? '$t – 开发中…' : '$t – 数据条数: $total',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
