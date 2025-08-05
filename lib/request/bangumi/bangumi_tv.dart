/*
  @Author Ligg
  @Time 2025/8/2
 */
import 'package:AnimeFlow/request/request.dart';
import 'package:dio/dio.dart';
import '../../utils/bangumi_analysis.dart';
import '../api/common_api.dart';

class BangumiTvService {

  //获取热度榜
  static Future<Map<String, dynamic>?> getRank(int count) async {
    final response = await httpRequest.get(
      CommonApi.bangumiTV,
      options: Options(
        headers: {
          'User-Agent': CommonApi.userAgent,
        },
      ),
      queryParameters: {'sort': 'trends','page': count},
    );
    return BangumiTvAnalysis.parseRankData(response.data);
  }
}
