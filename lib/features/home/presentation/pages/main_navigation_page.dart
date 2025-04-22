import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/cubit/navigation_cubit.dart';
import 'package:fyp/features/home/presentation/components/add_options_sheet.dart';
import 'package:fyp/features/home/presentation/components/floating_bottom_appbar.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/logbook/presentation/pages/journal_page.dart';
import 'package:fyp/features/maps/presentation/pages/map_page.dart';
import 'package:fyp/features/maps/presentation/pages/upload_fishing_spot_page.dart';
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
  bool showAddOptions = false;

  void toggleAddOptions() {
    setState(() {
      showAddOptions = !showAddOptions;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = context.read<AuthCubit>().currentUser;
      final notificationCubit = context.read<NotificationCubit>();

      if (currentUser != null) {
        await context.read<SOSCubit>().loadReceivedAlerts(currentUser.uid);
        notificationCubit.fetchNotifications(currentUser.uid);
        print("📥 Fetching SOS for: ${currentUser.uid}");
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
          print("👤 Current user UID: ${currentUser.uid}");

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

      child: Stack(
        children: [
          Scaffold(
            body: pages[navIndex],
            endDrawer: const MyDrawer(),
            bottomNavigationBar: Builder(
              builder:
                  (context) => FloatingBottomAppBar(
                    activeIndex: navIndex,
                    onItemSelected: (index) {
                      context.read<NavigationCubit>().setTab(index);
                    },
                    onDrawerPressed: () => Scaffold.of(context).openEndDrawer(),
                    onPressed: toggleAddOptions,
                  ),
            ),
          ),

          /// ✅ This is where your AddOptionsPopout appears
          if (showAddOptions)
            AddOptionsPopout(
              onAddPost: () {
                toggleAddOptions();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadPostPage()),
                );
              },
              onMarkSpot: () {
                toggleAddOptions();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadFishingSpotPage(),
                  ),
                );
              },
              onLogCatch: () {
                toggleAddOptions();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JournalPage(uid: currentUser?.uid ?? ''),
                  ),
                );
              },

              onDismiss: toggleAddOptions,
            ),
        ],
      ),
    );
  }
}
