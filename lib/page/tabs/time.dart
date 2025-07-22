import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/request/bangumi.dart';
import 'package:flutter/widgets.dart';

// 数据状态类
class CalendarState {
  final Map<String, dynamic>? data;
  final bool isLoading;

  CalendarState({this.data, this.isLoading = false});
}

// 数据提供者类
class CalendarProvider {
  final _stateController = StreamController<CalendarState>();
  Stream<CalendarState> get stateStream => _stateController.stream;

  CalendarProvider() {
    _stateController.add(CalendarState(isLoading: true));
  }

  Future<void> loadCalendar() async {
    _stateController.add(CalendarState(isLoading: true));

    try {
      final data = await BangumiService.getCalendar();
      _stateController.add(CalendarState(data: data, isLoading: false));
    } catch (e) {
      _stateController.add(CalendarState(isLoading: false));
    }
  }

  void dispose() {
    _stateController.close();
  }
}

// 动漫卡片组件
class AnimeCard extends StatelessWidget {
  final dynamic animeData;

  const AnimeCard({
    super.key,
    required this.animeData,
  });

  @override
  Widget build(BuildContext context) {
    final subject = animeData['subject'];
    final watchers = animeData['watchers'] ?? 0;

    final name = subject['nameCN']?.isNotEmpty == true
        ? subject['nameCN']
        : subject['name'];
    final imageUrl = subject['images']?['large'] ?? '';
    final score = subject['rating']?['score']?.toString() ?? '无评分';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildImage(imageUrl),
            ),
          ),
          // 信息区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 标题
                  Text(
                    name ?? '未知动漫',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 评分和关注数
                  _buildInfoSection(score, watchers),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(
        Icons.movie,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildInfoSection(String score, int watchers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 12, color: Colors.amber),
            const SizedBox(width: 2),
            Text(score, style: const TextStyle(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.visibility, size: 12, color: Colors.blue),
            const SizedBox(width: 2),
            Text('$watchers人关注', style: const TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

// 星期动漫网格组件
class WeeklyAnimeGrid extends StatelessWidget {
  final Map<String, dynamic> calendarData;

  const WeeklyAnimeGrid({
    super.key,
    required this.calendarData,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          // 星期标签栏
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _buildWeekTabs(),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // 星期内容
          Expanded(
            child: TabBarView(
              children: _buildWeekViews(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekTabs() {
    const weekNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekNames.asMap().entries.map((entry) {
      final dayIndex = entry.key + 1; // 1-7
      final dayName = entry.value;
      final animeCount = calendarData[dayIndex.toString()]?.length ?? 0;
      
      return Tab(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dayName),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$animeCount',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildWeekViews() {
    return List.generate(7, (index) {
      final dayIndex = index + 1; // 1-7
      final dayAnimes = calendarData[dayIndex.toString()] as List<dynamic>? ?? [];
      
      if (dayAnimes.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tv_off,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '今天没有新番',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return AnimeGrid(animes: dayAnimes);
    });
  }
}

// 单日动漫网格组件
class AnimeGrid extends StatelessWidget {
  final List<dynamic> animes;

  const AnimeGrid({
    super.key,
    required this.animes,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => AnimeCard(animeData: animes[index]),
              childCount: animes.length,
            ),
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }
}

// 主页面组件
class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> with AutomaticKeepAliveClientMixin {
  late CalendarProvider _calendarProvider;

  @override
  void initState() {
    super.initState();
    _calendarProvider = CalendarProvider();
    _calendarProvider.loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 keep alive
    return StreamBuilder<CalendarState>(
      stream: _calendarProvider.stateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data!;
          return _buildContent(state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildContent(CalendarState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.data != null) {
      return WeeklyAnimeGrid(calendarData: state.data!);
    } else {
      return const Center(child: Text("加载数据失败"));
    }
  }

  @override
  void dispose() {
    _calendarProvider.dispose();
    super.dispose();
  }
}
