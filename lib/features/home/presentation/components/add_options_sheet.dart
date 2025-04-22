import 'dart:ui';
import 'package:flutter/material.dart';

class AddOptionsPopout extends StatelessWidget {
  final VoidCallback onAddPost;
  final VoidCallback onMarkSpot;
  final VoidCallback onLogCatch;
  final VoidCallback onDismiss;

  const AddOptionsPopout({
    super.key,
    required this.onAddPost,
    required this.onMarkSpot,
    required this.onLogCatch,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///Tap outside to dismiss
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent, // must be non-null to detect taps
          ),
        ),

        ///Actual popout menu
        Positioned(
          bottom: 65, // stick to top of nav bar
          left: MediaQuery.of(context).size.width / 2 - 160,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Theme.of(context).colorScheme.inversePrimary,
                elevation: 12,
                shadowColor: Colors.black87,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Pill drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      _buildOption(label: "Add a Post", onTap: onAddPost),
                      _buildOption(
                        label: "Mark a Fishing Spot",
                        onTap: onMarkSpot,
                      ),
                      _buildOption(label: "Log a Catch", onTap: onLogCatch),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({required String label, required VoidCallback onTap}) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 12,
      title: Text(
        label,
        textAlign: TextAlign.center, // 👈 tells the text itself to center
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      onTap: onTap,
    );
  }
}
