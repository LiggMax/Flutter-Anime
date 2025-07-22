import '../request/request.dart';

class ApiService {
  // 获取动漫列表
  static Future<Map<String, dynamic>?> getAnimeList({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    try {
      final response = await httpRequest.get(
        '/api/anime/list',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
        },
      );
      return response.data;
    } catch (e) {
      print('获取动漫列表失败: $e');
      return null;
    }
  }

  // 获取动漫详情
  static Future<Map<String, dynamic>?> getAnimeDetail(String animeId) async {
    try {
      final response = await httpRequest.get('/api/anime/$animeId');
      return response.data;
    } catch (e) {
      print('获取动漫详情失败: $e');
      return null;
    }
  }

  // 搜索动漫
  static Future<Map<String, dynamic>?> searchAnime(String keyword) async {
    try {
      final response = await httpRequest.get(
        '/api/anime/search',
        queryParameters: {'keyword': keyword},
      );
      return response.data;
    } catch (e) {
      print('搜索动漫失败: $e');
      return null;
    }
  }

  // 获取热门动漫
  static Future<Map<String, dynamic>?> getPopularAnime() async {
    try {
      final response = await httpRequest.get('/api/anime/popular');
      return response.data;
    } catch (e) {
      print('获取热门动漫失败: $e');
      return null;
    }
  }

  // 用户登录
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await httpRequest.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      print('登录失败: $e');
      return null;
    }
  }

  // 用户注册
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await httpRequest.post(
        '/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      print('注册失败: $e');
      return null;
    }
  }
} 