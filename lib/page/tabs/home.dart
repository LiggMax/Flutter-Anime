import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/request/bangumi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CalendarProvider _calendarProvider;

  @override
  void initState() {
    super.initState();
    _calendarProvider = CalendarProvider();
    _calendarProvider.loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<CalendarState>(
        stream: _calendarProvider.stateStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data!;
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.data != null) {
              return _buildAnimeGrid(state.data!);
            } else {
              return const Center(child: Text("加载数据失败"));
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildAnimeGrid(Map<String, dynamic> calendarData) {
    // 获取所有动漫数据
    List<dynamic> allAnimes = [];
    calendarData.forEach((day, animes) {
      if (animes is List) {
        allAnimes.addAll(animes);
      }
    });

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
              (context, index) => _buildAnimeCard(allAnimes[index]),
              childCount: allAnimes.length,
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

  Widget _buildAnimeCard(dynamic animeData) {
    final subject = animeData['subject'];
    final watchers = animeData['watchers'] ?? 0;

    final name = subject['nameCN']?.isNotEmpty == true
        ? subject['nameCN']
        : subject['name'];
    final imageUrl = subject['images']?['large'] ?? '';
    final score = subject['rating']?['score']?.toString() ?? '无评分';
    final rank = subject['rating']?['rank']?.toString() ?? '无排名';

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
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.movie,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.movie,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            score,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$watchers人关注',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calendarProvider.dispose();
    super.dispose();
  }
}

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

class CalendarState {
  final Map<String, dynamic>? data;
  final bool isLoading;

  CalendarState({this.data, this.isLoading = false});
}
