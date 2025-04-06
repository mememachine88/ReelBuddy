import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/post/domain/entities/comments.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/storage/domain/storage_repo.dart';
import '../../presentation/cubits/post_states.dart';
import '../../domain/repos/post_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
    : super(PostInitial());

  // Create posts
  Future<void> createPost(Post post, String? imagePath) async {
    try {
      String? imageUrl; // Make it nullable

      // Handle image upload
      if (imagePath != null) {
        emit(PostUploading());
        imageUrl = await storageRepo.uploadPostImage(imagePath, post.id);
      }

      // Create a new post with the image URL (if available)
      final newPost = post.copyWith(imageUrl: imageUrl);

      // Ensure the post is created successfully
      await postRepo.createPost(newPost);

      // refetch all posts

      fetchAllPosts();
    } catch (e) {
      emit(PostError("Failed to create post: $e")); // Emit error state
    }
  }

  //fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Failed to fetch posts: $e"));
    }
  }

  //deleting posts
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostError("Failed to delete post: $e"));
    }
  }

  //toggle likes
  Future<void> toggleLikePost(String postId, String uid) async {
    try {
      await postRepo.toggleLikePost(postId, uid);
    } catch (e) {
      emit(PostError("Failed to like post $e"));
    }
  }

  //add comment
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
    } catch (e) {
      emit(PostError("Failed to add comment: $e"));
    }
  }

  //delete comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
    } catch (e) {
      emit(PostError("Error deleting comment: $e"));
    }
  }
}
