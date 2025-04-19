import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/cubit/navigation_cubit.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/maps/presentation/pages/map_page.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:fyp/features/post/presentation/pages/upload_post_page.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';
import 'package:fyp/features/weather/presentation/pages/weather_page.dart';
import 'package:fyp/features/sos/presentation/components/sos_alert_popup.dart';
import 'package:fyp/features/sos/data/firebase_sos_repo.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_state.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final mapPageKey = GlobalKey<MapPageState>();

  bool hasShownPopup = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = context.read<AuthCubit>().currentUser;
      final notificationCubit = context.read<NotificationCubit>();

      if (currentUser != null) {
        await context.read<SOSCubit>().loadReceivedAlerts(currentUser.uid);
        notificationCubit.fetchNotifications(currentUser.uid);
        print("📥 Fetching SOS for: ${currentUser?.uid}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    final navIndex = context.watch<NavigationCubit>().state;

    final List<Widget> pages = [
      const HomePage(),
      const WeatherPage(),
      const SizedBox(),
      MapPage(key: mapPageKey),
      ProfilePage(uid: currentUser?.uid ?? ''),
    ];

    return BlocListener<SOSCubit, SOSState>(
      listener: (context, state) async {
        final currentUser = context.read<AuthCubit>().currentUser;

        if (state is SOSLoaded && currentUser != null) {
          final alerts = state.alerts; // ✅ Now this is safe
          final unread = alerts.firstWhere(
            (alert) => !alert.isRead && alert.receiverUid == currentUser.uid,
            orElse: () => SOSAlert.empty(),
          );
          print("📋 All alerts fetched:");
          for (var alert in state.alerts) {
            print(
              "ID: ${alert.id} | Receiver: ${alert.receiverUid} | Read: ${alert.isRead}",
            );
          }
          print("👤 Current user UID: ${currentUser?.uid}");

          if (unread.id.isNotEmpty) {
            await FirebaseSOSRepo().markAlertAsRead(unread.id);
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (_) => SOSAlertPopup(alert: unread),
              );
            }
          }
        }
      },
      child: Scaffold(
        body: pages[navIndex],
        endDrawer: const MyDrawer(),
        bottomNavigationBar: Builder(
          builder:
              (context) => FloatingBottomAppBar(
                activeIndex: navIndex,
                onItemSelected: (index) {
                  context.read<NavigationCubit>().setTab(index);
                },
                onPressed: () {
                  if (navIndex == 3) {
                    mapPageKey.currentState?.handleAddPressedFromNavBar();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadPostPage()),
                    );
                  }
                },
                onDrawerPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
        ),
      ),
    );
  }
}
