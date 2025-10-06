import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hacker_news_api.dart';
import '../data/comment.dart';

final commentsProvider = FutureProvider.family<List<Comment>, List<int>>((ref, ids) async {
  return await HackerNewsApi.fetchComments(ids);
});
