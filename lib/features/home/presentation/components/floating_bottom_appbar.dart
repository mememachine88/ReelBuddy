import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar_tiles.dart';

class FloatingBottomAppBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onItemSelected;
  final VoidCallback onPressed;
  final VoidCallback onDrawerPressed;

  const FloatingBottomAppBar({
    Key? key,
    required this.activeIndex,
    required this.onItemSelected,
    required this.onPressed,
    required this.onDrawerPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Material(
        color: Theme.of(context).colorScheme.inversePrimary,
        elevation: 8,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60.0,
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingAppBarTile(
                icon: CupertinoIcons.house_fill,
                onTap: () => onItemSelected(0),
                isActive: activeIndex == 0,
                iconSize: 24.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.cloud_sun_bolt,
                onTap: () => onItemSelected(1),
                isActive: activeIndex == 1,
                iconSize: 30.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.plus_circle,
                onTap: onPressed,
                isActive: false,
                iconSize: 36.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.map,
                onTap: () => onItemSelected(3),
                isActive: activeIndex == 3,
                iconSize: 30.0,
              ),
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
