import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme_extensions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    // TODO: 从本地存储加载搜索历史
    _searchHistory = ['进击的巨人', '鬼灭之刃', '咒术回战', '间谍过家家'];
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchSuggestions.clear();
        });
      }
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // 模拟搜索建议
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _currentQuery == query) {
        setState(() {
          _isSearching = false;
          _searchSuggestions = [
            '$query 第一季',
            '$query 第二季',
            '$query 剧场版',
            '$query 特别篇',
          ];
        });
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _addToHistory(query.trim());
      _performSearch(query.trim());
      // TODO: 执行实际搜索
      print('搜索: $query');
    }
  }

  void _addToHistory(String query) {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
      // TODO: 保存到本地存储
    }
  }

  void _clearHistory() {
    setState(() {
      _searchHistory.clear();
    });
    // TODO: 清除本地存储
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: context.isDarkMode
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: context.isDarkMode
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          _buildSearchBar(),

          // 搜索内容
          Expanded(child: _buildSearchContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '搜索动漫、角色、声优...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.requestFocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: _onSearchSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_searchController.text.isEmpty) {
      return _buildSearchHistory();
    } else {
      return _buildSearchResults();
    }
  }

  Widget _buildSearchHistory() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: _clearHistory, child: const Text('清空')),
            ],
          ),
          const SizedBox(height: 8),
          ..._searchHistory.map((history) => _buildHistoryItem(history)),
          const SizedBox(height: 24),
        ],

        // 热门搜索
        Text(
          '热门搜索',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            '进击的巨人',
            '鬼灭之刃',
            '咒术回战',
            '间谍过家家',
            '海贼王',
            '火影忍者',
            '死神',
            '龙珠',
          ].map((tag) => _buildHotSearchTag(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('搜索中...'),
          ],
        ),
      );
    }

    if (_searchSuggestions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '没有找到相关结果',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchSuggestions.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchSuggestions[index]);
      },
    );
  }

  Widget _buildHistoryItem(String history) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(history),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _searchController.text = history;
        _onSearchSubmitted(history);
      },
    );
  }

  Widget _buildHotSearchTag(String tag) {
    return ActionChip(
      label: Text(tag),
      onPressed: () {
        _searchController.text = tag;
        _onSearchSubmitted(tag);
      },
      backgroundColor: context.isDarkMode ? Colors.grey[700] : Colors.grey[200],
    );
  }

  Widget _buildSearchResultItem(String result) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text(result),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: 跳转到搜索结果详情页
        print('选择搜索结果: $result');
      },
    );
  }
}
