import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/app.dart';
import 'package:fyp/features/fishID/presentation/pages/fish_scanner_page.dart';
import 'package:fyp/features/logbook/presentation/pages/add_logbook_page.dart';
import 'package:fyp/features/logbook/presentation/pages/journal_page.dart';
import 'package:fyp/features/notifications/domain/entities/notification.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';

import 'package:fyp/features/sos/domain/entities/sos.dart';
import 'package:fyp/features/sos/presentation/components/sos_confirmation_dialogue.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/presentation/components/my_drawer_tile.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/profile/presentation/pages/profile_page.dart';
import 'package:fyp/features/search/presentation/pages/search_page.dart';
import 'package:fyp/features/settings/pages/settings_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // Top spacing
              // Wrap only the icon with SafeArea
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Image.asset("assets/logo_color.png", height: 200),
              ),

              // Divider line
              Divider(color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(height: 20), // Spacing after the icon
              // Drawer tiles
              MyDrawerTile(
                title: "P R O F I L E",
                svgIconPath: "assets/user.svg",
                onTap: () {
                  //pop menu
                  Navigator.of(context).pop();

                  //get current uid
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  //navigate to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfilePage(
                            uid: uid,
                          ), // Ensure ProfilePage is implemented
                    ),
                  );
                },
              ),
              MyDrawerTile(
                title: "L O G B O O K",
                svgIconPath: "assets/fish-hook.svg",
                onTap: () {
                  Navigator.of(context).pop();
                  final user = context.read<AuthCubit>().currentUser;
                  final uid = user?.uid ?? '';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalPage(uid: uid),
                    ),
                  );
                },
              ),
              MyDrawerTile(
                title: "F I S H   I D",
                svgIconPath: "assets/qr-scan.svg",
                onTap: () {
                  Navigator.of(context).pop();
                  final currentUser = context.read<AuthCubit>().currentUser;
                  final uid = currentUser?.uid ?? ''; // fallback if null

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FishScannerPage(uid: uid),
                    ),
                  );
                },
              ),

              MyDrawerTile(
                title: "S. O. S",
                svgIconPath: "assets/emergency.svg",
                onTap: () async {
                  final rootContext = navigatorKey.currentContext!;

                  try {
                    // Request location permission
                    LocationPermission permission =
                        await Geolocator.checkPermission();

                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          const SnackBar(
                            content: Text("❌ Location permission denied"),
                          ),
                        );
                        return;
                      }
                    }

                    if (permission == LocationPermission.deniedForever) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "⚠ Location permission permanently denied. Please enable it in settings.",
                          ),
                        ),
                      );
                      await Geolocator.openAppSettings();
                      return;
                    }

                    //  Safe to get location
                    final position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    // Confirm SOS
                    final confirmed = await showDialog<bool>(
                      context: rootContext,
                      builder:
                          (_) => SOSConfirmationDialog(
                            location: LatLng(
                              position.latitude,
                              position.longitude,
                            ),
                            onConfirm:
                                () => Navigator.of(rootContext).pop(true),
                          ),
                    );

                    // Send SOS if confirmed
                    if (confirmed == true) {
                      final authUser =
                          rootContext.read<AuthCubit>().currentUser;

                      if (authUser != null) {
                        final profile = await rootContext
                            .read<ProfileCubit>()
                            .getUserProfile(authUser.uid);

                        if (profile != null) {
                          for (String followerUid in profile.followers) {
                            final sos = SOSAlert(
                              id: const Uuid().v4(),
                              senderUid: authUser.uid,
                              senderName: profile.name,
                              senderUsername: profile.username,
                              senderProfileImageUrl:
                                  profile.profileImageUrl ?? '',
                              latitude: position.latitude,
                              longitude: position.longitude,
                              timestamp: DateTime.now(),
                              receiverUid: followerUid,
                              isRead: false,
                            );

                            await rootContext.read<SOSCubit>().sendSOS(
                              sos,
                              [followerUid], // Send to this follower only
                            );

                            await rootContext.read<SOSCubit>().sendSOS(
                              sos,
                              profile.followers,
                            );
                          }
                          final notification = AppNotification(
                            id: '', // Firestore will generate ID
                            type: 'sos',
                            title: '🚨 SOS Alert',
                            message: '${profile.name} sent an SOS!',
                            timestamp: DateTime.now(),
                            isRead: false,
                            senderUid: profile.uid,
                            senderUsername: profile.username,
                            senderProfileImageUrl:
                                profile.profileImageUrl ?? '',
                          );

                          // Send it to each follower
                          for (final followerUid in profile.followers) {
                            await context
                                .read<NotificationCubit>()
                                .sendNotification(followerUid, notification);
                          }

                          ScaffoldMessenger.of(rootContext).showSnackBar(
                            const SnackBar(
                              content: Text("📍 SOS sent to your followers"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(rootContext).showSnackBar(
                            const SnackBar(
                              content: Text("⚠ Failed to fetch profile info"),
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      rootContext,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
              ),

              MyDrawerTile(
                title: "S E A R C H",
                svgIconPath: "assets/search.svg",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    ),
              ),

              MyDrawerTile(
                title: "S E T T I N G S",
                svgIconPath: "assets/settings.svg",
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
              ),

              //Search
              const SizedBox(height: 50), // Add spacing above the LOG OUT tile

              SafeArea(
                child: MyDrawerTile(
                  title: "L O G   O U T",
                  svgIconPath: "assets/logout.svg",
                  onTap: () => context.read<AuthCubit>().logout(),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
