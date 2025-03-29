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

      // Create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: "",
      );

      // Return user
      return user;
    } catch (e) {
      throw Exception("Login Failed: $e");
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
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
        'createdAt': FieldValue.serverTimestamp(), // Timestamp for registration
      });

      // Create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      // Return user
      return user;
    } catch (e) {
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
    final userDoc =
        await firestore.collection('users').doc(firebaseUser.uid).get();

    if (userDoc.exists) {
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: userDoc.data()?['name'] ?? "", // Fallback to empty name
      );
    }

    // If Firestore document does not exist, return minimal AppUser
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: "");
  }
}
