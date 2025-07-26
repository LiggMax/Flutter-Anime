import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi.dart';
import 'package:AnimeFlow/modules/episodes_data.dart';
import 'package:AnimeFlow/page/play/episode.dart';

class DetailPage extends StatefulWidget {
  final int? animeId;
  final String? animeName;

  const DetailPage({super.key, this.animeId, this.animeName});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Episode> _episodes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    try {
      ///获取剧集信息
      final response = await BangumiService.getEpisodesByID(widget.animeId!);
      if (response != null) {
        final episodesData = EpisodesData.fromJson(response);
        _episodes = episodesData.episodes;
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.animeName != null) ...[
            Text(
              widget.animeName!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
          ],
          if (_loading) ...[
            const Center(child: CircularProgressIndicator()),
          ] else ...[
            // 使用新创建的EpisodeCountRow组件
            EpisodeCountRow(
              episodeCount: _episodes.length,
              onRefresh: _fetchEpisodes,
              episodes: _episodes, // 传递剧集列表
            ),
            const SizedBox(height: 10),
            // Display episode list
            EpisodeList(episodes: _episodes),
          ],
        ],
      ),
    );
  }
}