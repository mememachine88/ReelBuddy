import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/post/domain/entities/comments.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection callled posts
  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection("posts");
  @override
  Future<void> createPost(Post post) async {
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await postCollection.doc(postId).delete();
    } catch (e) {
      throw Exception("Error deleting post: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postSnapshot =
          await postCollection.orderBy("timestamp", descending: true).get();

      // convert each firestore document to a list of posts
      final List<Post> allPosts =
          postSnapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
      return allPosts;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String uid) async {
    try {
      // fetch post by user id
      final postSnapshot =
          await postCollection.where("uid", isEqualTo: uid).get();

      //convert firestore doc to posts

      final userPosts =
          postSnapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
      return userPosts;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String uid) async {
    try {
      //get post document from firestore
      final postDoc = await postCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        //check if user liked
        final hasLiked = post.likes.contains(uid);

        //update liked list
        if (hasLiked) {
          post.likes.remove(uid); //unlike
        } else {
          post.likes.add(uid); //like
        }

        //update postdoc
        await postCollection.doc(postId).update({"likes": post.likes});
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error toggling likes: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      //get post document
      final postDoc = await postCollection.doc(postId).get();
      // convert json to post
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //add comment
        post.comments.add(comment);

        //update firestore
        await postCollection.doc(postId).update({
          "comments": post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      //get post document
      final postDoc = await postCollection.doc(postId).get();
      // convert json to post
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //add comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        //update firestore
        await postCollection.doc(postId).update({
          "comments": post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error deleting comment: $e");
    }
  }
}
