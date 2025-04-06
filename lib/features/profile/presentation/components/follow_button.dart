/*
Follow Button
 */

import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onPressed,
  });

  //Build UI
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      //button
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,
          padding: EdgeInsets.all(25),
          color:
              isFollowing
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.inversePrimary,
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
              color:
                  Theme.of(
                    context,
                  ).colorScheme.primary, // Set text color to primary
            ),
          ),
        ),
      ),
    );
  }
}
