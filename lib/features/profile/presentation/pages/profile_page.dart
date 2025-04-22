import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/domain/entities/app_user.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/presentation/components/add_options_sheet.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';
import 'package:fyp/features/notifications/domain/entities/notification.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:fyp/features/post/presentation/components/post_tile.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/profile/presentation/components/profile_stats.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:fyp/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:fyp/features/profile/presentation/pages/follower_page.dart';
import 'package:fyp/features/profile/presentation/components/follow_button.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar.dart';
import 'package:fyp/features/post/presentation/pages/upload_post_page.dart';
import 'package:fyp/features/home/cubit/navigation_cubit.dart';
import 'package:fyp/features/maps/presentation/pages/upload_fishing_spot_page.dart';
import 'package:fyp/features/logbook/presentation/pages/stats_page.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_cubit.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_state.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showAddOptions = false;

  void toggleAddOptions() {
    setState(() {
      showAddOptions = !showAddOptions;
    });
  }

  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      profileCubit.fetchUserProfile(widget.uid);
    }
  }

  void followButtonPressed() async {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) return;

    final profileUser = profileState.profile;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    try {
      await profileCubit.toggleFollow(currentUser!.uid, widget.uid);

      if (!isFollowing && widget.uid != currentUser!.uid) {
        final notification = AppNotification(
          id: '',
          type: 'follow',
          title: '👤 New Follower',
          message: '${currentUser!.username} started following you!',
          timestamp: DateTime.now(),
          isRead: false,
          senderUid: currentUser!.uid,
          senderUsername: currentUser!.username,
          senderProfileImageUrl: profileUser.profileImageUrl ?? '',
        );

        await context.read<NotificationCubit>().sendNotification(
          widget.uid,
          notification,
        );
      }
    } catch (_) {
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

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
          final user = profileState.profile;

          return Stack(
            children: [
              Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  automaticallyImplyLeading: true,
                ),
                endDrawer: const MyDrawer(),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                imageUrl: user.profileImageUrl,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) => Icon(
                                      Icons.person,
                                      size: 72,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                                      context
                                          .read<ProfileCubit>()
                                          .fetchUserProfile(widget.uid);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.bio,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child:
                                    isOwnPost
                                        ? ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => EditProfilePage(
                                                      user: user,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text("Edit Profile"),
                                        )
                                        : ElevatedButton(
                                          onPressed: followButtonPressed,
                                          child: Text(
                                            user.followers.contains(
                                                  currentUser!.uid,
                                                )
                                                ? "Unfollow"
                                                : "Follow",
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.bar_chart),
                                  label: const Text("View Stats"),
                                  onPressed: () async {
                                    final logbookCubit =
                                        context.read<LogbookCubit>();
                                    await logbookCubit.loadEntries(user.uid);
                                    final state = logbookCubit.state;

                                    if (state is LogbookLoaded) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => StatsPage(
                                                entries: state.entries,
                                              ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Failed to load stats"),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Posts",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<PostCubit, PostState>(
                          builder: (context, state) {
                            if (state is PostLoaded) {
                              final userPosts =
                                  state.posts
                                      .where((post) => post.uid == widget.uid)
                                      .toList();

                              return ListView.builder(
                                itemCount: userPosts.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final post = userPosts[index];
                                  return PostTile(
                                    post: post,
                                    onDeletePressed: () {
                                      context.read<PostCubit>().deletePost(
                                        post.id,
                                      );
                                    },
                                  );
                                },
                              );
                            } else if (state is PostLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return const Center(child: Text("No posts yet"));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar:
                    isOwnPost
                        ? FloatingBottomAppBar(
                          activeIndex: -1,
                          onItemSelected: (index) {
                            context.read<NavigationCubit>().setTab(index);
                            Navigator.pop(context);
                          },
                          onPressed: toggleAddOptions,
                          onDrawerPressed:
                              () => _scaffoldKey.currentState?.openEndDrawer(),
                        )
                        : null,
              ),
              if (showAddOptions)
                AddOptionsPopout(
                  onAddPost: () {
                    toggleAddOptions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadPostPage()),
                    );
                  },
                  onMarkSpot: () {
                    toggleAddOptions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UploadFishingSpotPage(),
                      ),
                    );
                  },
                  onLogCatch: () {
                    toggleAddOptions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadPostPage()),
                    );
                  },
                  onDismiss: toggleAddOptions,
                ),
            ],
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
