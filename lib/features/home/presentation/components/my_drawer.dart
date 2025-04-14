import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/presentation/components/my_drawer_tile.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:fyp/features/search/presentation/pages/search_page.dart';
import 'package:fyp/features/settings/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // Top spacing
              // Wrap only the icon with SafeArea
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Image.asset("assets/logo_color.png", height: 200),
              ),

              // Divider line
              Divider(color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(height: 20), // Spacing after the icon
              // Drawer tiles
              MyDrawerTile(
                title: "P R O F I L E",
                svgIconPath: "assets/user.svg",
                onTap: () {
                  //pop menu
                  Navigator.of(context).pop();

                  //get current uid
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  //navigate to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfilePage(
                            uid: uid,
                          ), // Ensure ProfilePage is implemented
                    ),
                  );
                },
              ),
              MyDrawerTile(
                title: "L O G B O O K",
                svgIconPath: "assets/fish-hook.svg",
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              HomePage(), // Ensure ProfilePage is implemented
                    ),
                  );
                },
              ),

              MyDrawerTile(
                title: "F I S H  I D",
                svgIconPath: "assets/qr-scan.svg",
                onTap: () {},
              ),
              MyDrawerTile(
                title: "S.  O.  S",
                svgIconPath: "assets/emergency.svg",
                onTap: () {},
              ),
              MyDrawerTile(
                title: "S E A R C H",
                svgIconPath: "assets/search.svg",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    ),
              ),

              MyDrawerTile(
                title: "S E T T I N G S",
                svgIconPath: "assets/settings.svg",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
              ),

              //Search
              const SizedBox(height: 50), // Add spacing above the LOG OUT tile

              SafeArea(
                child: MyDrawerTile(
                  title: "L O G   O U T",
                  svgIconPath: "assets/logout.svg",
                  onTap: () => context.read<AuthCubit>().logout(),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
