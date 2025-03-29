import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/data/firebase_auth_repo.dart';
import 'package:fyp/features/auth/domain/repo/auth_repo.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_states.dart';
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
  //auth repo

  final authRepo = FirebaseAuthRepo();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
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
              return const HomePage(); // Make sure HomePage exists in your imports
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
            // Handle side effects or navigation here (if needed)
          },
        ),
      ),
    );
  }
}
