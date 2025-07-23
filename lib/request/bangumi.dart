
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
}
