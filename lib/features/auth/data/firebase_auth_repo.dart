import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/domain/repo/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Firestore instance

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // Attempt to sign in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //fetch user document from firestore
      DocumentSnapshot userDoc =
          await firestore
              .collection("users")
              .doc(userCredential.user!.uid)
              .get();
      // Create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userDoc["name"],
        username: userDoc["username"],
      );

      // Return user
      return user;
    } catch (e) {
      throw Exception("Login Failed: $e");
    }
  }

  @override
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
    String username,
  ) async {
    try {
      // Attempt to sign up
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store user information in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(), // Timestamp for registration
      });

      // Create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        username: username,
      );

      // Return user
      return user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth exceptions
      if (e.code == 'email-already-in-use') {
        // Handle email already in use
        throw Exception(
          "The email address is already in use by another account.",
        );
      } else {
        // Handle other errors
        throw Exception("Sign Up Failed: ${e.message}");
      }
    } catch (e) {
      // Handle any other exceptions
      throw Exception("Sign Up Failed: $e");
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // Get currently logged-in user
    final firebaseUser = firebaseAuth.currentUser;

    // No user logged in
    if (firebaseUser == null) {
      return null;
    }

    // Fetch user data from Firestore
    DocumentSnapshot userDoc =
        await firestore.collection("users").doc(firebaseUser.uid).get();

    //check user exists
    if (!userDoc.exists) {
      return null;
    }

    //user exists
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc["name"],
      username: userDoc["username"],
    );
  }
}
