/*
Login Page
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/components/my_button.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/components/video_background.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  //Login Button Pressed
  void login() {
    //prepare email and pw
    final String email = emailController.text;
    final String pw = pwController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    //ensure email and pw not empty

    if (email.isNotEmpty && pw.isNotEmpty) {
      //login
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  //Build UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Background
          const VideoBackground(),

          // Foreground Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Image.asset("assets/logo_color.png", height: 300),
                    const SizedBox(height: 25),

                    // Welcome Back Message
                    Text(
                      "Welcome back!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .white, // Ensure visibility over video background
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Email TextField
                    MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 25),

                    // Password TextField
                    MyTextField(
                      controller: pwController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),

                    // Login Button
                    MyButton(onTap: login, text: "Login"),
                    const SizedBox(height: 25),

                    // Register Now Link
                    RichText(
                      text: TextSpan(
                        text: "Not a member? ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        children: [
                          TextSpan(
                            text: "Register now",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap =
                                      widget
                                          .togglePages, // Fixed the gesture recognizer
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
