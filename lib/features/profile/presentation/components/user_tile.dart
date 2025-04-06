import 'package:flutter/material.dart';
import 'package:fyp/features/profile/domain/entities/profile_user.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final hasProfileImage =
        user.profileImageUrl != null &&
        user.profileImageUrl.trim().isNotEmpty &&
        user.profileImageUrl.toLowerCase() != 'null';

    return ListTile(
      title: Text(user.username),
      subtitle: Text(user.email),

      leading:
          hasProfileImage
              ? CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(user.profileImageUrl),
              )
              : CircleAvatar(
                radius: 24,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),

      trailing: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).colorScheme.tertiary,
      ),

      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(uid: user.uid)),
          ),
    );
  }
}
