import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/presentation/components/my_drawer_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 60), // Top spacing
            // Wrap only the icon with SafeArea
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SafeArea(
                child: Icon(
                  Icons.person,
                  size: 90,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),

            // Divider line
            Divider(color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(height: 30), // Spacing after the icon
            // Drawer tiles
            MyDrawerTile(
              title: "H O M E",
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
              title: "P R O F I L E",
              svgIconPath: "assets/user.svg",
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ProfilePage(), // Ensure ProfilePage is implemented
                  ),
                );
              },
            ),
            MyDrawerTile(
              title: "W E A T H E R",
              svgIconPath: "assets/weather.svg",
              onTap: () {},
            ),
            MyDrawerTile(
              title: "M A P S",
              svgIconPath: "assets/map-marker.svg",
              onTap: () {},
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
              title: "S E T T I N G S",
              svgIconPath: "assets/settings.svg",
              onTap: () {},
            ),

            const SizedBox(height: 180), // Add spacing above the LOG OUT tile

            MyDrawerTile(
              title: "L O G   O U T",
              svgIconPath: "assets/logout.svg",
              onTap: () => context.read<AuthCubit>().logout(),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
