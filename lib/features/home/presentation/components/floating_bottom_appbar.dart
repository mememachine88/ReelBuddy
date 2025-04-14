import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar_tiles.dart';

class FloatingBottomAppBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onItemSelected;
  final void Function() onPressed;
  final void Function() onDrawerPressed;

  const FloatingBottomAppBar({
    super.key,
    required this.activeIndex,
    required this.onItemSelected,
    required this.onPressed,
    required this.onDrawerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60.0,
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home
              FloatingAppBarTile(
                icon: CupertinoIcons.house_fill,
                onTap: () => onItemSelected(0),
                onPressed: () {},
                isActive: activeIndex == 0,
                iconSize: 24.0,
              ),
              // Weather
              FloatingAppBarTile(
                icon: CupertinoIcons.cloud_sun_bolt,
                onTap: () => onItemSelected(1),
                isActive: activeIndex == 1,
                iconSize: 30.0,
              ),
              // Center Add Button
              FloatingAppBarTile(
                icon: CupertinoIcons.plus_circle,
                onTap: onPressed,
                isActive: false,
                iconSize: 36.0, // Slightly larger to emphasize
              ),
              // Maps
              FloatingAppBarTile(
                icon: CupertinoIcons.map,
                onTap: () => onItemSelected(3),
                isActive: activeIndex == 3,
                iconSize: 30.0,
              ),
              // Menu
              FloatingAppBarTile(
                icon: CupertinoIcons.square_grid_2x2,
                onTap: onDrawerPressed,
                isActive: activeIndex == 4,
                iconSize: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
