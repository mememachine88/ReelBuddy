import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp/features/post/domain/entities/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //image
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //name
            Text(post.username),
            //delete button
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
          ],
        ),
        CachedNetworkImage(
          imageUrl: post.imageUrl,
          height: 440,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(height: 440),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ],
    );
  }
}
