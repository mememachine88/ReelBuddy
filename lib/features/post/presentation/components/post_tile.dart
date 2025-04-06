import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/post/domain/entities/comments.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/presentation/components/comment_tile.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:intl/intl.dart';

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
  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    // Update the backend
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // Revert changes if there is an error
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
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
            title: Text("Add a new comment"),
            content: MyTextField(
              controller: commentTextController,
              hintText: "Add a comment",
              obscureText: false,
            ),

            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),

              //save button
              TextButton(
                onPressed: () {
                  addComment();
                  Navigator.of(context).pop();
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }

  //create new comment
  void addComment() {
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
    print("[Debug] username: $currentUser");

    // Optimistically update the UI
    setState(() {
      widget.post.comments.add(newComment);
    });

    // Clear the input
    commentTextController.clear();

    // Call cubit once and handle rollback
    context.read<PostCubit>().addComment(widget.post.id, newComment).catchError(
      (error) {
        setState(() {
          widget.post.comments.removeWhere(
            (comment) => comment.id == newComment.id,
          );
        });
      },
    );
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
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            actions: [
              //cancel
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
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
                    color: Theme.of(context).colorScheme.primary,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //profile picture
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                        imageUrl: postUser!.profileImageUrl,
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.person,
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
                      : const Icon(Icons.person),
                  //name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      widget.post.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const Spacer(),
                  //delete button
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
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 440,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 440),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      //like button
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              widget.post.likes.contains(currentUser!.uid)
                                  ? Colors
                                      .red // Change to red when liked
                                  : Colors
                                      .black, // Default color when not liked
                        ),
                      ),
                      Text(widget.post.likes.length.toString()),
                    ],
                  ),
                ),

                //comment button
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(Icons.comment),
                ),

                Text(widget.post.comments.length.toString()),
                const Spacer(),

                //timestamp
                Text(formattedDate),
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
                return const Center(child: CircularProgressIndicator());
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
