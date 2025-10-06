import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hacker_news_api.dart';
import '../data/story.dart';

final storiesProvider = FutureProvider.family<List<Story>, String>((ref, category) async {
  final ids = await HackerNewsApi.fetchStoryIds(category);
  final limitedIds = ids.take(20).toList();
  final stories = await Future.wait(
    limitedIds.map((id) async {
      final json = await HackerNewsApi.fetchStory(id);
      return Story.fromJson(json);
    }),
  );
  return stories;
});
