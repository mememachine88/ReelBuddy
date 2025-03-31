/*

Post States

 */
import '../../domain/entities/post.dart';

abstract class PostState {}

//initial
class PostInitial extends PostState {}

//loading
class PostLoading extends PostState {}

//uploading
class PostUploading extends PostState {}

//error
class PostError extends PostState {
  final String message;
  PostError(this.message);
}

//loaded
class PostLoaded extends PostState {
  final List<Post> posts;
  PostLoaded(this.posts);
}
