// 动漫详情页参数
class AnimeDataArguments {
  final int animeId;
  final String? animeName; // 可选的动漫名称，用于页面标题
  final String? imageUrl;  // 可选的封面图片

  const AnimeDataArguments({
    required this.animeId,
    this.animeName,
    this.imageUrl,
  });
} 