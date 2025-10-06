import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/new_stories_screen.dart';
import 'screens/top_stories_screen.dart';
import 'screens/best_stories_screen.dart';
import 'screens/story_details_screen.dart';
import 'data/story.dart';

final GoRouter router = GoRouter(
  initialLocation: '/new',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/new',
          name: 'new',
          builder: (context, state) => const NewStoriesScreen(),
        ),
        GoRoute(
          path: '/top',
          name: 'top',
          builder: (context, state) => const TopStoriesScreen(),
        ),
        GoRoute(
          path: '/best',
          name: 'best',
          builder: (context, state) => const BestStoriesScreen(),
        ),
        GoRoute(
          path: '/details',
          name: 'details',
          builder: (context, state) {
      final story = state.extra;
      return story is Story
        ? StoryDetailsScreen(story: story)
        : const Scaffold(body: Center(child: Text('No story data')));
          },
        ),
      ],
    ),
  ],
);

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final List<String> _routes = ['/new', '/top', '/best'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.go(_routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fiber_new),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Top',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Best',
          ),
        ],
      ),
    );
  }
}
