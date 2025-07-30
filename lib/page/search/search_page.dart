import 'package:AnimeFlow/routes/route_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:AnimeFlow/utils/theme_extensions.dart';
import 'package:AnimeFlow/request/bangumi.dart';
import 'package:AnimeFlow/modules/search_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchHistory = [];
  SearchData? _searchData;
  bool _isSearching = false;
  String _currentQuery = '';
  bool _isGridView = false; // 布局切换状态：false为列表布局，true为网格布局

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

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('search_history');
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        setState(() {
          _searchHistory = historyList.cast<String>();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('加载搜索历史失败: $e');
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchData = null;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final result = await BangumiService.search(query);
      if (mounted && _currentQuery == query) {
        setState(() {
          _isSearching = false;
          if (result != null) {
            _searchData = SearchDataParser.parseSearchResponse(result);
          } else {
            _searchData = null;
          }
        });
      }
    } catch (e) {
      if (mounted && _currentQuery == query) {
        setState(() {
          _isSearching = false;
          _searchData = null;
        });
      }
      print('搜索失败: $e');
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _addToHistory(query.trim()); // 异步调用，
      _performSearch(query.trim());
    }
  }

  Future<void> _addToHistory(String query) async {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });

      // 保存到本地存储
      await _saveSearchHistory();
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_searchHistory);
      await prefs.setString('search_history', historyJson);
    } catch (e) {
      print('保存搜索历史失败: $e');
    }
  }

  Future<void> _clearHistory() async {
    setState(() {
      _searchHistory.clear();
    });

    // 清除本地存储
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
    } catch (e) {
      print('清除搜索历史失败: $e');
    }
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
      padding: const EdgeInsets.all(10),
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
            SizedBox(height: 10),
            Text('搜索中...'),
          ],
        ),
      );
    }

    if (_searchData == null || _searchData!.data.isEmpty) {
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

    return Column(
      children: [
        // 搜索结果统计和操作按钮
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Text(
                '找到 ${_searchData!.total} 个结果',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const Spacer(),
              // 布局切换按钮
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              // 排序按钮
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  _sortResults(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'score', child: Text('按评分排序')),
                  const PopupMenuItem(value: 'date', child: Text('按日期排序')),
                  const PopupMenuItem(
                    value: 'collection',
                    child: Text('按收藏数排序'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 搜索结果列表
        Expanded(child: _isGridView ? _buildGridView() : _buildListView()),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      itemCount: _searchData!.data.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchData!.data[index]);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: _searchData!.data.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_searchData!.data[index]);
      },
    );
  }

  Widget _buildGridItem(SearchAnimeItem anime) {
    return GestureDetector(
      onTap: () => _onAnimeTap(anime),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: anime.coverImage.isNotEmpty
                  ? Image.network(
                      anime.coverImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // 标题
          Text(
            anime.displayName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _sortResults(String sortType) {
    if (_searchData == null) return;

    setState(() {
      switch (sortType) {
        case 'score':
          _searchData!.data.sort((a, b) => b.score.compareTo(a.score));
          break;
        case 'date':
          _searchData!.data.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return b.date!.compareTo(a.date!);
          });
          break;
        case 'collection':
          _searchData!.data.sort(
            (a, b) => b.collection.collect.compareTo(a.collection.collect),
          );
          break;
      }
    });
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

  Widget _buildSearchResultItem(SearchAnimeItem anime) {
    return GestureDetector(
      onTap: () => _onAnimeTap(anime),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧封面图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: anime.coverImage.isNotEmpty
                  ? Image.network(
                      anime.coverImage,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),

            const SizedBox(width: 12),

            // 右侧信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    anime.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 基本信息
                  Row(
                    children: [
                      if (anime.date != null && anime.date!.isNotEmpty) ...[
                        Text(
                          anime.date!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (anime.eps > 0) ...[
                        Text(
                          '全${anime.eps}话',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 标签信息
                  if (anime.tags.isNotEmpty) ...[
                    Text(
                      anime.tags.take(3).map((tag) => tag.name).join('/'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // 制作信息
                  if (anime.infobox.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final director = anime.infobox.firstWhere(
                          (box) => box.key == '导演' || box.key == '监督',
                          orElse: () => AnimeInfoBox(key: '', value: ''),
                        );
                        if (director.key.isNotEmpty) {
                          return Text(
                            '制作: ${director.valueString}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],

                  // 评分信息
                  Row(
                    children: [
                      if (anime.score > 0) ...[
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          anime.score.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${anime.rating.rank}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${anime.rating.total}人评',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 搜索结果跳转
  void _onAnimeTap(SearchAnimeItem anime) {
    RouteHelper.goToAnimeData(
      context,
      animeId: anime.id,
      animeName: anime.nameCn,
      imageUrl: anime.image,
    );
  }
}
