/*
  @Author Ligg
  @Time 2025/8/7
 */
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:AnimeFlow/request/request.dart';
import 'package:AnimeFlow/request/api/bangumi/p1_api.dart';
import 'package:dio/dio.dart';
import '../api/common_api.dart';

class BangumiUser {
  ///获取用户信息
  static Future<UserInfo?> getUserinfo(String username,{token}) async {
    final response = await httpRequest.get(
      BangumiP1Api.bangumiUserInfo.replaceAll('{username}', username),
      options: Options(headers: {'User-Agent': CommonApi.bangumiUserAgent})
    );
    return UserInfo.fromJson(response.data);
  }
}
