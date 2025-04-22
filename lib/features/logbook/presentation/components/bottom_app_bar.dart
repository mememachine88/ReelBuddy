import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar_tiles.dart';

class FloatingBottomAppBar extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onItemSelected;
  final void Function() onPressed;

  const FloatingBottomAppBar({
    super.key,
    required this.activeIndex,
    required this.onItemSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60.0,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingAppBarTile(
                icon: CupertinoIcons.house_fill,
                onTap: () => onItemSelected(0),
                isActive: activeIndex == 0,
                iconSize: 24.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.map,
                onTap: () => onItemSelected(1),
                isActive: activeIndex == 1,
                iconSize: 26.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.plus_circle,
                onTap: onPressed,
                isActive: false,
                iconSize: 36.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.chart_bar_alt_fill,
                onTap: () => onItemSelected(2),
                isActive: activeIndex == 2,
                iconSize: 26.0,
              ),
              FloatingAppBarTile(
                icon: CupertinoIcons.book_fill, // Journal icon
                onTap: () => onItemSelected(3),
                isActive: activeIndex == 3,
                iconSize: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
