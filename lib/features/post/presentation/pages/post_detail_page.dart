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
        centerTitle: true,
        title: Text(
          'Post Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: true,
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
