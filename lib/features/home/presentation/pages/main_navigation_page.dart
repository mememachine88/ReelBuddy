import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/cubit/navigation_cubit.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/maps/presentation/pages/map_page.dart';
import 'package:fyp/features/post/presentation/pages/upload_post_page.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:fyp/features/weather/presentation/pages/weather_page.dart';

class MainNavigationPage extends StatelessWidget {
  MainNavigationPage({super.key});
  final mapPageKey = GlobalKey<MapPageState>();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    final navIndex = context.watch<NavigationCubit>().state;

    final List<Widget> pages = [
      const HomePage(),
      const WeatherPage(),
      const SizedBox(), // Center button (Upload)
      MapPage(key: mapPageKey),
      ProfilePage(uid: currentUser!.uid),
    ];
    final bool isOnMapPage = navIndex == 3;

    return Scaffold(
      body: pages[navIndex],
      endDrawer: const MyDrawer(),
      bottomNavigationBar: Builder(
        builder:
            (context) => FloatingBottomAppBar(
              activeIndex: navIndex,
              onItemSelected:
                  (index) => context.read<NavigationCubit>().setTab(index),
              onPressed: () {
                if (isOnMapPage) {
                  mapPageKey.currentState?.handleAddPressedFromNavBar();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UploadPostPage()),
                  );
                }
              },

              onDrawerPressed:
                  () => Scaffold.of(context).openEndDrawer(), // ✅ now it works
            ),
      ),
    );
  }
}
