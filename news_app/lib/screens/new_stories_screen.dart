import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/story.dart';
import '../data/hacker_news_api.dart';
import '../data/story.dart';

class NewStoriesScreen extends StatefulWidget {
  const NewStoriesScreen({Key? key}) : super(key: key);

  @override
  State<NewStoriesScreen> createState() => _NewStoriesScreenState();
}

class _NewStoriesScreenState extends State<NewStoriesScreen> {
  late Future<List<int>> _idsFuture;

  @override
  void initState() {
    super.initState();
    _idsFuture = HackerNewsApi.fetchStoryIds('new');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<List<int>>(
        future: _idsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final ids = snapshot.data ?? [];
          if (ids.isEmpty) {
            return const Center(child: Text('No stories found.'));
          }
          return ListView.builder(
            itemCount: ids.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return FutureBuilder<Map<String, dynamic>>(
                future: HackerNewsApi.fetchStory(ids[index]),
                builder: (context, storySnapshot) {
                  if (storySnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(title: Text('Loading...')),
                    );
                  }
                  if (storySnapshot.hasError || storySnapshot.data == null) {
                    return const Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(title: Text('Error loading story')),
                    );
                  }
                  final story = Story.fromJson(storySnapshot.data!);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      title: Text(story.title),
                      onTap: () {
                        GoRouter.of(context).push('/details', extra: story);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
