import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class FloatingAppBarTile extends StatelessWidget {
  final IconData icon;
  final void Function() onTap;
  final bool isActive;
  final double iconSize; // New parameter to indicate if the tile is active
  final void Function()? onPressed; // Optional parameter for the center button

  const FloatingAppBarTile({
    super.key,
    required this.icon,
    this.iconSize = 24,
    required this.onTap,
    this.isActive = false,
    this.onPressed, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color:
                isActive
                    ? Theme.of(context)
                        .colorScheme
                        .secondary // Active color
                    : Theme.of(context).colorScheme.primary, // Default color
          ),
          const SizedBox(height: 4), // Spacing between icon and text
        ],
      ),
    );
  }
}
