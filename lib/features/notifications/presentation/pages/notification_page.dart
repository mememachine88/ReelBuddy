import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/notifications/presentation/components/notification_tile.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_state.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = context.read<AuthCubit>().currentUser!.uid;

    @override
    void initState() {
      super.initState();
      uid = context.read<AuthCubit>().currentUser!.uid;

      final cubit = context.read<NotificationCubit>();
      cubit.fetchNotifications(uid).then((_) {
        final state = cubit.state;
        if (state is NotificationLoaded) {
          for (var n in state.notifications.where((n) => !n.isRead)) {
            cubit.markAsRead(uid, n.id); // ✅ Use the actual notification ID
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notifications"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: LoadingAnimationWidget.dotsTriangle(
                color: Theme.of(context).colorScheme.inversePrimary,
                size: 70,
              ),
            );
          }

          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }

          if (state is NotificationLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return const Center(child: Text("No notifications yet"));
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(notification: notification);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
