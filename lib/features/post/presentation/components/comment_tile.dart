import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/post/domain/entities/comments.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  //current user
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.uid == currentUser!.uid);
  }

  //show options for deleting comments

  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Delete Post?",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              //delete button
              TextButton(
                onPressed: () {
                  context.read<PostCubit>().deleteComment(
                    widget.comment.postId,
                    widget.comment.id,
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //comment tile UI
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          //name
          Text(
            widget.comment.username,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),

          //comment text
          Text(widget.comment.text),
          const Spacer(),

          //delete button
          if (isOwnPost)
            GestureDetector(onTap: showOptions, child: Icon(Icons.more_horiz)),
        ],
      ),
    );
  }
}
