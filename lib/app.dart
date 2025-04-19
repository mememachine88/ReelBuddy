import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fyp/features/auth/data/firebase_auth_repo.dart';

import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_states.dart';
import 'package:fyp/features/fishID/data/firebase_scan_repo.dart';
import 'package:fyp/features/fishID/data/service/fishial_api_service.dart';
import 'package:fyp/features/fishID/presentation/cubits/scan_cubit.dart';
import 'package:fyp/features/home/cubit/navigation_cubit.dart';
import 'package:fyp/features/home/presentation/pages/main_navigation_page.dart';
import 'package:fyp/features/maps/domain/services/map_service.dart';
import 'package:fyp/features/maps/presentation/cubit/map_cubit.dart';
import 'package:fyp/features/notifications/data/firebase_notification_repo.dart';
import 'package:fyp/features/notifications/domain/repo/notification_repo.dart';
import 'package:fyp/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:fyp/features/post/data/firebase_post_repo.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/profile/data/firebase_profile_repo.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/search/data/firebase_search_repo.dart'
    show FirebaseSearchRepo;
import 'package:fyp/features/search/presentation/cubits/search_cubit.dart';
import 'package:fyp/features/sos/data/firebase_sos_repo.dart';
import 'package:fyp/features/sos/presentation/cubit/sos_cubit.dart';

import 'package:fyp/features/storage/data/firebase_storage_repo.dart';

import 'package:fyp/themes/theme_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';

/* 

Root Level of App

repository for database

Bloc Providers For state management
- auth
- profile
- post

*/
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  // Auth repo
  final authRepo = FirebaseAuthRepo();

  // Profile repo
  final profileRepo = FirebaseProfileRepo();

  // Storage repo
  final storageRepo = FirebaseStorageRepo();

  // Post repo
  final postRepo = FirebasePostRepo(); // Ensure this class exists

  //searh repo
  final searchRepo = FirebaseSearchRepo(); // Ensure this class exists

  final MapService mapService = MapService(); // Ensure this class exists

  final sosRepo = FirebaseSOSRepo();

  final notificationRepo = FirebaseNotificationRepo();

  final fishScannerRepo = FirebaseScanRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),
        // Profile cubit
        BlocProvider<ProfileCubit>(
          create:
              (context) => ProfileCubit(
                profileRepo: profileRepo,
                storageRepo: storageRepo,
              ),
        ),
        // ✅ Add PostCubit
        BlocProvider<PostCubit>(
          create:
              (context) => PostCubit(
                postRepo: postRepo, // Ensure this is correctly implemented
                storageRepo: storageRepo,
              ),
        ),

        //search cubit
        BlocProvider<SearchCubit>(create: (context) => SearchCubit(searchRepo)),
        //theme cubit
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        //navigation cubit
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),

        //map cubit
        BlocProvider(create: (_) => MapCubit(MapService())),

        BlocProvider<SOSCubit>(create: (context) => SOSCubit(sosRepo)),

        BlocProvider<ScanCubit>(
          create:
              (context) => ScanCubit(
                fishialApi: FishialApiService(),
                firebaseRepo: FirebaseScanRepo(),
              ),
        ),

        BlocProvider(
          create:
              (context) =>
                  NotificationCubit(notificationRepo: notificationRepo),
        ),
      ],
      //main app widget
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder:
            (context, currentTheme) => MaterialApp(
              navigatorKey: navigatorKey, // ✅ this line
              debugShowCheckedModeBanner: false,
              theme: currentTheme, // ✅ This comes from ThemeCubit
              home: BlocConsumer<AuthCubit, AuthState>(
                builder: (context, authState) {
                  print(authState);
                  if (authState is Unauthenticated) {
                    return const AuthPage();
                  }
                  if (authState is Authenticated) {
                    return MainNavigationPage();
                  } else {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
              ),
            ),
      ),
    );
  }
}
