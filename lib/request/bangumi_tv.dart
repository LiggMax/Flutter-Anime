/*
  @Author Ligg
  @Time 2025/8/2
 */
import 'package:AnimeFlow/request/request.dart';
import 'package:logging/logging.dart';
import '../utils/bangumi_analysis.dart';
import 'api.dart';

class BangumiTvService {
  static final Logger _log = Logger('BangumiTvService');

  //获取热度榜
  static Future<Map<String, dynamic>?> getRank(int count) async {
    final response = await httpRequest.get(
      Api.bangumiTV,
      queryParameters: {'sort': 'trends','page': count},
    );
    return BangumiTvAnalysis.parseRankData(response.data);
  }
}
