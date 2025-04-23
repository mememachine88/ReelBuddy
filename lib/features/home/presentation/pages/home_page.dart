import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';
import 'package:fyp/features/post/presentation/components/post_tile.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_states.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:fyp/features/weather/presentation/pages/weather_page.dart';
import 'package:fyp/features/notifications/presentation/pages/notification_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey for controlling the endDrawer
  late final PostCubit postCubit = context.read<PostCubit>();
  int _activeIndex = 0; // Tracks the active page

  void _updateActivePage(int newIndex) {
    setState(() {
      _activeIndex = newIndex;

      // Open the endDrawer when the Grid icon is selected
      if (newIndex == 4) {
        _scaffoldKey.currentState?.openEndDrawer();
      }
    });
  }

  void handleNavTap(int index) {
    setState(() {
      _activeIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WeatherPage()),
        );
        break;
      //insert case 3
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ProfileCubit>().getUserProfile(uid);
    }
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  //build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    final profileImage = user?.photoURL;

    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          "R e e l   B u d d y",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),

      actions: [
        IconButton(
          icon: Icon(
            CupertinoIcons.bell,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  //build body

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostLoading || state is PostUploading) {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 70,
            ),
          );
        } else if (state is PostLoaded) {
          final allPosts = state.posts;

          if (allPosts.isEmpty) {
            return const Center(child: Text("No posts available"));
          }

          return ListView.builder(
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              final post = allPosts[index];
              return PostTile(
                post: post,
                onDeletePressed: () => deletePost(post.id),
              );
            },
          );
        } else if (state is PostError) {
          return Center(child: Text(state.message));
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      endDrawer: const MyDrawer(),
      body: _buildBody(context),
    );
  }
}
