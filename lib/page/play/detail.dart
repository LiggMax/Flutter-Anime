import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi.dart';

class DetailPage extends StatefulWidget {
  final int? animeId;
  final String? animeName;

  const DetailPage({super.key, this.animeId, this.animeName});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> _episodes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    try {
      final response = await BangumiService.getEpisodesByID(widget.animeId!);
      if (response != null) {
        setState(() {
          _episodes = response['episodes'];
          _loading = false;
        });
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
            // 这里可以添加更多剧集信息的展示
          ],
        ],
      ),
    );
  }
}

///获取剧集信息

class GetEpisodes {
  Future<Map<String, dynamic>?> getEpisodesByID(int id) async {
    final response = await BangumiService.getEpisodesByID(id);
    return response;
  }
}
