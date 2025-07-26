class Episode {
  final String airdate;
  final String name;
  final String nameCn;
  final String duration;
  final String desc;
  final int ep;
  final double sort;
  final int id;
  final int subjectId;
  final int comment;
  final int type;
  final int disc;
  final int durationSeconds;

  Episode({
    required this.airdate,
    required this.name,
    required this.nameCn,
    required this.duration,
    required this.desc,
    required this.ep,
    required this.sort,
    required this.id,
    required this.subjectId,
    required this.comment,
    required this.type,
    required this.disc,
    required this.durationSeconds,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      airdate: json['airdate'] as String,
      name: json['name'] as String,
      nameCn: json['name_cn'] as String,
      duration: json['duration'] as String,
      desc: json['desc'] as String,
      ep: json['ep'] as int,
      sort: (json['sort'] as int).toDouble(),
      id: json['id'] as int,
      subjectId: json['subject_id'] as int,
      comment: json['comment'] as int,
      type: json['type'] as int,
      disc: json['disc'] as int,
      durationSeconds: json['duration_seconds'] as int,
    );
  }
}

class EpisodesData {
  final List<Episode> episodes;
  final int total;
  final int limit;
  final int offset;

  EpisodesData({
    required this.episodes,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory EpisodesData.fromJson(Map<String, dynamic> json) {
    var episodesList = json['data'] as List;
    List<Episode> episodes = episodesList.map((e) => Episode.fromJson(e)).toList();

    return EpisodesData(
      episodes: episodes,
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }
}