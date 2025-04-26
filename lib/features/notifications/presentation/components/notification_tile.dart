import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/notifications/domain/entities/notification.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/post/presentation/cubits/post_states.dart';
import 'package:fyp/features/post/presentation/pages/post_detail_page.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';
import 'package:fyp/features/sos/presentation/components/sos_alert_popup.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const NotificationTile({super.key, required this.notification});

  void _showSosAlertPopup(BuildContext context) async {
    try {
      // Get all SOS alerts from Firestore for this user (receiver)
      final uid = notification.senderUid;

      // You probably already have a fetch method like this:
      // context.read<SOSCubit>().loadReceivedAlerts(currentUser.uid);

      final cubit = context.read<SOSCubit>();
      final state = cubit.state;

      if (state is SOSLoaded) {
        final matchingAlert = state.alerts.firstWhere(
          (alert) => alert.senderUid == notification.senderUid,
          orElse: () => SOSAlert.empty(), // fallback
        );

        if (matchingAlert.id.isNotEmpty) {
          //Show the popup
          showDialog(
            context: context,
            builder: (_) => SOSAlertPopup(alert: matchingAlert),
          );
        } else {
          //No matching alert
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No recent SOS alert found.")),
          );
        }
      } else {
        // Not loaded
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SOS alerts not available right now.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _handleTap(context),

      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: notification.senderProfileImageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Icon(Icons.person, size: 24),
            errorWidget:
                (context, url, error) => const Icon(Icons.person, size: 24),
          ),
        ),
      ),

      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: Text(
        _formatTimeAgo(notification.timestamp),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    switch (notification.type) {
      case 'like':
      case 'comment':
        _openPostIfExists(context, notification.postId);
        break;

      case 'follow':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(uid: notification.senderUid),
          ),
        );
        break;

      case 'sos':
        _showSosAlertPopup(context);
        break;

      default:
        break;
    }
  }

  void _openPostIfExists(BuildContext context, String? postId) {
    print(postId);
    if (postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing post information.")),
      );
      return;
    }

    final postState = context.read<PostCubit>().state;

    if (postState is PostLoaded) {
      try {
        final post = postState.posts.firstWhere((p) => p.id == postId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This post was deleted or is no longer available."),
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays}d ago';
  }
}
