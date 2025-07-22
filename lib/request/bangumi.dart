import 'request.dart';
import 'api.dart';

class BangumiService {
  //获取每日放送
  static Future<Map<String, dynamic>?> getCalendar() async {
    try {
      final response = await httpRequest.get(Api.bangumiCalendar);
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
