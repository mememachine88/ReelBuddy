import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';
import 'package:fyp/features/post/presentation/components/post_tile.dart';
import 'package:fyp/features/post/domain/entities/post.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/post/presentation/pages/upload_post_page.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:fyp/features/weather/presentation/pages/weather_page.dart';

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
    return AppBar(
      title: Text(
        "Home",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(
            CupertinoIcons.bell,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          onPressed: () {
            // TODO: Handle notifications
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
          return const Center(child: CircularProgressIndicator());
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
