import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<ProfileUser>> searchUsers(String query) async {
    try {
      final result =
          await FirebaseFirestore.instance
              .collection("users")
              .where("name", isGreaterThanOrEqualTo: query)
              .where("name", isLessThanOrEqualTo: "$query\uf8ff")
              .get();

      return result.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Add document ID as UID
        return ProfileUser.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }
}
