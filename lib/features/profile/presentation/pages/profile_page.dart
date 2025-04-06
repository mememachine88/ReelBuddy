import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/post/presentation/components/post_tile.dart';
import 'package:fyp/features/profile/presentation/components/profile_stats.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/profile/presentation/components/bio_box.dart';
import 'package:fyp/features/profile/presentation/components/follow_button.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fyp/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:fyp/features/profile/presentation/pages/follower_page.dart';
import 'package:fyp/features/profile/presentation/components/profile_stats.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  //posts

  //current user
  late AppUser? currentUser = authCubit.currentUser;

  // On startup
  @override
  void initState() {
    super.initState();

    // Load user profile
    profileCubit.fetchUserProfile(widget.uid);
  }

  // detect when profilepage is reused but with differnt uid
  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      profileCubit.fetchUserProfile(widget.uid);
    }
  }

  //Follow unfollow
  void followButtonPressed() async {
    print('[DEBUG] Follow button tapped');
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }
      //follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });
    await profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((
      error,
    ) {
      //revert changes
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }
        //follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    //is own profile
    bool isOwnPost = (widget.uid == currentUser!.uid);

    // Get current posts from PostCubit
    final postState = context.watch<PostCubit>().state;
    int postCount = 0;
    if (postState is PostLoaded) {
      postCount =
          postState.posts.where((post) => post.uid == widget.uid).length;
    }
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (profileState is ProfileLoaded) {
          final user = profileState.profileUser; // Extract user here

          return Scaffold(
            // App Bar
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                user.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              actions: [
                if (isOwnPost)
                  //edit profile button
                  IconButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          ),
                        ),
                    icon: SvgPicture.asset(
                      "assets/settings.svg",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),

            // Body
            body: ListView(
              children: [
                // Email
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                //Profile Picture
                //no image selected -> display existing profile pic
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,

                  //loading....
                  placeholder:
                      (context, url) => const CircularProgressIndicator(),

                  //error failed to load
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.secondary,
                      ),

                  //loaded
                  imageBuilder:
                      (context, imageProvider) => Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                ),

                SizedBox(height: 25),

                //profile stats aka followers and following
                ProfileStats(
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  postCount: postCount,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => FollowerPage(
                              followers: user.followers,
                              following: user.following,
                            ),
                      ),
                    );

                    // Refetch the profile once you're back
                    context.read<ProfileCubit>().fetchUserProfile(widget.uid);
                  },
                ),

                const SizedBox(height: 25),
                //follow button
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),

                SizedBox(height: 15),
                //Bio box
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Pushes content to the left
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ), // Adds left padding
                      child: Text(
                        "Bio",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                BioBox(text: user.bio),

                //Posts
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 25),
                  child: Row(
                    children: [
                      Text(
                        "Posts",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                //list of posts from this user
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    //post loaded
                    if (state is PostLoaded) {
                      //filter posts
                      final userPosts =
                          state.posts
                              .where((post) => post.uid == widget.uid)
                              .toList();
                      postCount = userPosts.length;
                      return ListView.builder(
                        itemCount: postCount,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          //get individual post
                          final post = userPosts[index];

                          //return as post tile
                          return PostTile(
                            post: post,
                            onDeletePressed:
                                () => context.read<PostCubit>().deletePost(
                                  post.id,
                                ),
                          );
                        },
                      );
                    }
                    //loading
                    else if (state is PostLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text("No posts yet"));
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("No profile found...")),
          );
        }
      },
    );
  }
}
