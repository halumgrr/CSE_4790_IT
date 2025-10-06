import 'package:dio/dio.dart';
import 'comment.dart';

class HackerNewsApi {
  static final Dio _dio = Dio();
  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';

  static Future<List<int>> fetchStoryIds(String category) async {
    final response = await _dio.get('$baseUrl/${category}stories.json');
    if (response.statusCode == 200) {
      final List ids = response.data;
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load story ids');
    }
  }

  static Future<Map<String, dynamic>> fetchStory(int id) async {
    final response = await _dio.get('$baseUrl/item/$id.json');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load story');
    }
  }
  static Future<List<Comment>> fetchComments(List<int> ids) async {
    if (ids.isEmpty) return [];
    final comments = await Future.wait(
      ids.map((id) async {
        final response = await _dio.get('$baseUrl/item/$id.json');
        if (response.statusCode == 200 && response.data != null) {
          return Comment.fromJson(response.data);
        }
        return null;
      }),
    );
    return comments.whereType<Comment>().toList();
  }
}
