import 'package:flutter/material.dart';
import '../data/story.dart';
import '../providers/comments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class StoryDetailsScreen extends ConsumerWidget {
  final Story story;
  const StoryDetailsScreen({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.fromMillisecondsSinceEpoch(story.time * 1000);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
    final commentsAsync = ref.watch(commentsProvider(story.kids));
    return Scaffold(
      appBar: AppBar(
        title: Text(story.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(story.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Date: $formattedDate'),
            const SizedBox(height: 8),
            if (story.url.isNotEmpty)
              Text('Link: ${story.url}', style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 16),
            if (story.text != null && story.text!.isNotEmpty)
              HtmlWidget(story.text!),
            if (story.text == null || story.text!.isEmpty)
              const Text('No description available.'),
            const SizedBox(height: 24),
            Text('Comments', style: Theme.of(context).textTheme.titleMedium),
            commentsAsync.when(
              data: (comments) => comments.isEmpty
                  ? const Text('No comments.')
                  : Column(
                      children: comments.map((comment) => _CommentWidget(comment: comment, depth: 0)).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading comments: $err'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentWidget extends ConsumerWidget {
  final Comment comment;
  final int depth;
  const _CommentWidget({Key? key, required this.comment, this.depth = 0}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.fromMillisecondsSinceEpoch(comment.time * 1000);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
    final childCommentsAsync = ref.watch(commentsProvider(comment.kids));
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.by, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              if (comment.text != null && comment.text!.isNotEmpty)
                HtmlWidget(comment.text!),
              if (comment.text == null || comment.text!.isEmpty)
                const Text('No comment text.'),
              if (comment.kids.isNotEmpty)
                childCommentsAsync.when(
                  data: (childComments) => Column(
                    children: childComments
                        .map((child) => _CommentWidget(comment: child, depth: depth + 1))
                        .toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: LinearProgressIndicator(),
                  ),
                  error: (err, stack) => Text('Error loading replies: $err'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
