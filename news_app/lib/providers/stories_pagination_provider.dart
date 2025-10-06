import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hacker_news_api.dart';
import '../data/story.dart';

class StoriesPaginationState {
  final List<Story> stories;
  final bool isLoading;
  final bool hasMore;
  final int nextIndex;
  final Object? error;

  StoriesPaginationState({
    required this.stories,
    required this.isLoading,
    required this.hasMore,
    required this.nextIndex,
    this.error,
  });

  StoriesPaginationState copyWith({
    List<Story>? stories,
    bool? isLoading,
    bool? hasMore,
    int? nextIndex,
    Object? error,
  }) {
    return StoriesPaginationState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      nextIndex: nextIndex ?? this.nextIndex,
      error: error,
    );
  }
}

class StoriesPaginationNotifier extends StateNotifier<StoriesPaginationState> {
  final String category;
  List<int> _allIds = [];
  static const int batchSize = 20;

  StoriesPaginationNotifier(this.category)
      : super(StoriesPaginationState(
          stories: [],
          isLoading: false,
          hasMore: true,
          nextIndex: 0,
        )) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      _allIds = await HackerNewsApi.fetchStoryIds(category);
      // Debug print for best stories
      if (category == 'best') {
        print('Best stories IDs fetched: \'${_allIds.length}\'');
      }
      if (_allIds.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false, error: 'No stories found');
        return;
      }
      await loadMore();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final end = (state.nextIndex + batchSize).clamp(0, _allIds.length);
      final idsToFetch = _allIds.sublist(state.nextIndex, end);
      final stories = await Future.wait(
        idsToFetch.map((id) async {
          final json = await HackerNewsApi.fetchStory(id);
          return Story.fromJson(json);
        }),
      );
      // Debug: print first few story titles
      for (var i = 0; i < stories.length && i < 5; i++) {
        print('Story $i: title="${stories[i].title}"');
      }
      final newStories = [...state.stories, ...stories];
      final hasMore = end < _allIds.length;
      if (newStories.isEmpty && !hasMore) {
        state = state.copyWith(
          stories: newStories,
          isLoading: false,
          hasMore: false,
          nextIndex: end,
          error: 'No valid stories found',
        );
      } else {
        state = state.copyWith(
          stories: newStories,
          isLoading: false,
          hasMore: hasMore,
          nextIndex: end,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

final storiesPaginationProvider = StateNotifierProvider.family<StoriesPaginationNotifier, StoriesPaginationState, String>(
  (ref, category) => StoriesPaginationNotifier(category),
);
