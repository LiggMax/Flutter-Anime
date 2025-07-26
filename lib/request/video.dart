/*
  @Author Ligg
  @Time 2025/7/26
 */
import 'package:dio/dio.dart';
import 'request.dart';

// 获取视频源
class VideoService {
  static const String websiteUrl = 'https://dm1.xfdm.pro';
  static const String searchUrl = 'https://dm1.xfdm.pro/search.html?wd=';
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';

  static Future<Map<String, dynamic>?> getVideoSource(
    String keyword,
    int ep,
  ) async {
    try {
      final response = await httpRequest.get(
        searchUrl + keyword,
        options: Options(headers: {'User-Agent': userAgent}),
      );
      print('搜索结果: $response');
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
