import 'package:flutter/material.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/presentation/components/post_tile.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: PostTile(
          post: post,
          onDeletePressed: () {}, // can leave empty if not needed
        ),
      ),
    );
  }
}
