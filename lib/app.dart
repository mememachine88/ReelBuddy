import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/data/firebase_auth_repo.dart';
import 'package:fyp/features/auth/domain/repo/auth_repo.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_states.dart';
import 'package:fyp/features/post/data/firebase_post_repo.dart';
import 'package:fyp/features/post/presentation/cubits/post_cubit.dart';
import 'package:fyp/features/profile/data/firebase_profile_repo.dart';
import 'package:fyp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:fyp/features/storage/data/firebase_storage_repo.dart';
import 'package:fyp/features/storage/domain/storage_repo.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'themes/light_mode.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';

/* 

Root Level of App

repository for database

Bloc Providers For state management
- auth
- profile
- post

*/

class MyApp extends StatelessWidget {
  // Auth repo
  final authRepo = FirebaseAuthRepo();

  // Profile repo
  final profileRepo = FirebaseProfileRepo();

  // Storage repo
  final storageRepo = FirebaseStorageRepo();

  // Post repo
  final postRepo = FirebasePostRepo(); // Ensure this class exists

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);
            if (authState is Unauthenticated) {
              return const AuthPage();
            }
            if (authState is Authenticated) {
              return const HomePage();
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
    );
  }
}
