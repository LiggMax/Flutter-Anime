class Api {
  // 每日放送
  static const String bangumiCalendar = 'https://next.bgm.tv/p1/calendar';
  // 从条目ID获取详细信息
  static const String bangumiInfoByID = 'https://api.bgm.tv/v0/subjects';
  // 从条目ID获取剧集ID
  static const String bangumiEpisodeByID = 'https://api.bgm.tv/v0/episodes';
  // 条目搜索
  static const String bangumiRankSearch = 'https://api.bgm.tv/v0/search/subjects?limit={0}&offset={1}';
  // bangumi请求头
  static const String bangumiUserAgent = 'Flutter-Anime/1.0.0 (https://github.com/LiggMax/Flutter-Anime.git)';
  //常规请求头
  static const String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';
}
