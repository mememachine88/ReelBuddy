/*o

outline all the possible outcomes of post
 */

import 'package:flutter/material.dart';
import 'package:fyp/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostByUserId(String uid);
}
