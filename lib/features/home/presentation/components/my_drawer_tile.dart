import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final String svgIconPath;
  final void Function()? onTap;

  const MyDrawerTile({
    super.key,
    required this.title,
    required this.svgIconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        svgIconPath, // Path to your SVG file
        height: 24,
        width: 24,
        color:
            Theme.of(
              context,
            ).colorScheme.inversePrimary, // Apply theme color to SVG icon
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              Theme.of(
                context,
              ).colorScheme.tertiary, // Apply tertiary color to text
          fontWeight: FontWeight.bold, // Optional: Make text bold for emphasis
        ),
      ),
      onTap: onTap,
    );
  }
}
