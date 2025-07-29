import 'package:logging/logging.dart';
import 'request.dart';
import 'api.dart';

class BangumiService {
  static final Logger _log = Logger('BangumiService');

  //获取每日放送
  static Future<Map<String, dynamic>?> getCalendar() async {
    try {
      final response = await httpRequest.get(Api.bangumiCalendar);
      return response.data;
    } catch (e) {
      _log.severe('获取每日放送失败: $e');
      return null;
    }
  }

  // 获取条目详情
  static Future<Map<String, dynamic>?> getInfoByID(int id) async {
    try {
      final response = await httpRequest.get('${Api.bangumiInfoByID}/$id');
      return response.data;
    } catch (e) {
      _log.severe('获取条目详情失败: $e');
      return null;
    }
  }

  //获取剧集详情
  static Future<Map<String, dynamic>?> getEpisodesByID(int id) async {
    try {
      final response = await httpRequest.get(
        Api.bangumiEpisodeByID,
        queryParameters: {'subject_id': id, 'limit': 100, 'offset': 0},
      );
      return response.data;
    } catch (e) {
      _log.severe('获取剧集详情失败: $e');
      return null;
    }
  }

  //条目搜索
  static Future<Map<String, dynamic>?> search(String keyword) async {
    try {
      final response = await httpRequest.post(
        Api.bangumiRankSearch.replaceAll('{0}', '20').replaceAll('{1}', '0'),
        data: {'keyword': keyword, 'sort': 'heat'},
      );
      return response.data;
    } catch (e) {
      _log.severe('条目搜索失败: $e');
      return null;
    }
  }
}
