import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/notifications/domain/entities/notification.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:fyp/features/post/domain/entities/comments.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/presentation/components/comment_tile.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  bool showHeart = false;
  bool isUnliked = false;

  //only delete own post
  bool isOwnPost = false;
  //current User
  AppUser? currentUser;

  //post user
  ProfileUser? postUser;

  //on startup
  @override
  void initState() {
    super.initState();
    getcurrenttUser();
    fetchPostUser();
  }

  void getcurrenttUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.uid == currentUser!.uid;
  }

  void fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.uid);
    if (!mounted) return; // prevent setState on disposed widget

    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*
  
  LIKES

   */
  //user taps like button
  void toggleLikePost() async {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    // Update the backend
    try {
      await postCubit.toggleLikePost(widget.post.id, currentUser!.uid);

      // Only send notification if the user liked (not unliked)
      if (!isLiked && widget.post.uid != currentUser!.uid) {
        final notification = AppNotification(
          id: '',
          type: 'like',
          title: 'New Like',
          message: '${currentUser!.username} liked your post!',
          timestamp: DateTime.now(),
          isRead: false,
          senderUid: currentUser!.uid,
          senderUsername: currentUser!.username,
          senderProfileImageUrl: postUser?.profileImageUrl ?? '',
          postId: widget.post.id,
        );

        await context.read<NotificationCubit>().sendNotification(
          widget.post.uid,
          notification,
        );
      }
    } catch (error) {
      // Revert UI if failed
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    }
  }

  /* 
  
  Comment
  
   */

  // comment text controller
  final commentTextController = TextEditingController();

  //open comment box
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              "Add a new comment",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            content: MyTextField(
              controller: commentTextController,
              hintText: "Add a comment",
              obscureText: false,
            ),

            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),

              //save button
              TextButton(
                onPressed: () {
                  addComment();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  //create new comment
  void addComment() async {
    final text = commentTextController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      uid: currentUser!.uid,
      username: currentUser!.username,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      widget.post.comments.add(newComment);
    });

    commentTextController.clear();

    try {
      await context.read<PostCubit>().addComment(widget.post.id, newComment);

      //  Only notify if commenting on someone else’s post
      if (widget.post.uid != currentUser!.uid) {
        final notification = AppNotification(
          id: '',
          type: 'comment',
          title: 'New Comment',
          message: '${currentUser!.username} commented on your post!',
          timestamp: DateTime.now(),
          isRead: false,
          senderUid: currentUser!.uid,
          senderUsername: currentUser!.username,
          senderProfileImageUrl: postUser?.profileImageUrl ?? '',
          postId: widget.post.id, //Use postUser
        );

        await context.read<NotificationCubit>().sendNotification(
          widget.post.uid,
          notification,
        );
      }
    } catch (error) {
      // Rollback on failure
      setState(() {
        widget.post.comments.removeWhere(
          (comment) => comment.id == newComment.id,
        );
      });
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //show options when delete
  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Delete Post?",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            actions: [
              //cancel
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),

              //delete
              TextButton(
                onPressed: () {
                  widget.onDeletePressed!();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    // Format the date to "day month (in English) year"
    String formattedDate = DateFormat(
      'd MMMM yyyy',
    ).format(widget.post.timestamp);
    return Container(
      child: Column(
        children: [
          //Top section
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: widget.post.uid),
                  ),
                ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  //  Profile Picture
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                        imageUrl: postUser!.profileImageUrl,
                        errorWidget:
                            (context, url, error) => Icon(
                              CupertinoIcons.person_fill,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                        imageBuilder:
                            (context, imageProvider) => Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      )
                      : const Icon(CupertinoIcons.person_fill),

                  const SizedBox(width: 12),

                  // Username + Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (widget.post.location != null &&
                            widget.post.location!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.location_solid,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                //  ensures location text fits without overflow
                                child: Text(
                                  widget.post.location!,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Delete button (if owner)
                  if (isOwnPost)
                    IconButton(
                      onPressed: showOptions,
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          //image
          // Double-tap to like with animated heart
          GestureDetector(
            onDoubleTap: () async {
              final isLiked = widget.post.likes.contains(currentUser!.uid);

              // Set the appropriate icon
              setState(() {
                isUnliked = isLiked; // if already liked, we're unliking
                showHeart = true;
              });

              toggleLikePost(); // perform the like/unlike action

              await Future.delayed(const Duration(seconds: 1));
              if (mounted) setState(() => showHeart = false);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  height: 440,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(height: 440),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),

                // Animated heart overlay
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showHeart ? 1.0 : 0.0,
                  child: Icon(
                    isUnliked
                        ? CupertinoIcons.heart_slash_circle
                        : CupertinoIcons.heart_circle,
                    color:
                        isUnliked
                            ? Theme.of(context).colorScheme.primary
                            : Colors.red,
                    size: 100,
                    shadows: const [
                      Shadow(blurRadius: 10, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Like + Comment row
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color:
                              widget.post.likes.contains(currentUser!.uid)
                                  ? Colors.red
                                  : Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(widget.post.likes.length.toString()),
                    ],
                  ),
                ),

                // Comment button remains unchanged
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    CupertinoIcons.chat_bubble,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(widget.post.comments.length.toString()),

                const Spacer(),

                // Date
                Text(DateFormat('d MMM yyyy').format(widget.post.timestamp)),
              ],
            ),
          ),

          //Caption Box
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                //username
                Text(
                  widget.post.username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 20),
                //text
                Text(widget.post.text),
              ],
            ),
          ),

          //Comment section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostLoaded) {
                final post = state.posts.firstWhere(
                  (post) => post.id == widget.post.id,
                  orElse: () => widget.post, // Ensure a default post
                );

                if (post.comments.isEmpty) {
                  return Center(child: Text("No comments yet"));
                }

                return ListView.builder(
                  itemCount: post.comments.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    //get individual comment
                    final comment = post.comments[index];

                    return CommentTile(comment: comment);
                  },
                );
              } else if (state is PostLoading) {
                return Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 70,
                  ),
                );
              } else if (state is PostError) {
                return Center(child: Text(state.message));
              } else {
                return Center(child: Text("No comments yet")); // Default case
              }
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
