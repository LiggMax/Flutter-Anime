import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi.dart';
import 'package:AnimeFlow/modules/episodes_data.dart';

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
            Text('剧集数量: ${_episodes.length}'),
            const SizedBox(height: 10),
            // Display episode list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _episodes.length,
              itemBuilder: (context, index) {
                final episode = _episodes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      episode.nameCn.isNotEmpty 
                          ? episode.nameCn 
                          : episode.name.isNotEmpty 
                              ? episode.name 
                              : '第${episode.ep}集',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('第${episode.ep}集'),
                        if (episode.airdate.isNotEmpty) 
                          Text('播出日期: ${episode.airdate}'),
                        if (episode.duration.isNotEmpty) 
                          Text('时长: ${episode.duration}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}