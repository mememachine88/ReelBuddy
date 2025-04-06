//show followers and following

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/profile/presentation/components/user_tile.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // AppBar
        appBar: AppBar(
          bottom: TabBar(
            // Set the colors here
            labelColor: Theme.of(context).colorScheme.tertiary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ), // Selected tab text color
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ), // Unselected tab text color
            tabs: [Tab(text: "Followers"), Tab(text: "Following")],
          ),
        ),

        // TabBar view
        body: TabBarView(
          children: [
            _buildUserList(followers, "No followers", context),
            _buildUserList(following, "No following", context),
          ],
        ),
      ),
    );
  }

  //build user list
  Widget _buildUserList(
    List<String> uids,
    String emptyMessage,
    BuildContext context,
  ) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
          itemCount: uids.length,
          itemBuilder: (context, index) {
            //get each uid
            final uid = uids[index];

            return FutureBuilder(
              future: context.read<ProfileCubit>().getUserProfile(uid),
              builder: (context, snapshot) {
                //user loaded
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return UserTile(user: user);
                }
                //loading
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text("Loading..."));
                }
                //not found
                else {
                  return ListTile(title: Text("User not found..."));
                }
              },
            );
          },
        );
  }
}
