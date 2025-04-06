import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/components/my_button.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_states.dart';
import 'package:fyp/themes/light_mode.dart';

class RegisterPage extends StatefulWidget {
  final void Function()?
  togglePages; // Fixed `void function()` to `void Function()`
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPwController = TextEditingController();
  final usernameController = TextEditingController();

  Future<bool> isEmailUsed(String email) async {
    try {
      final QuerySnapshot result =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();
      return result
          .docs
          .isNotEmpty; // If documents exist, email is already in use
    } catch (e) {
      print("Error checking email: $e");
      return false; // Return false if there's an error
    }
  }

  bool isValidUsername(String username) {
    final usernameRegex = RegExp(
      r'^[a-zA-Z0-9_]+$',
    ); // Only alphanumeric and underscores
    return usernameRegex.hasMatch(username) && username.length >= 3;
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      return query.docs.isNotEmpty; // If any document exists, username is taken
    } catch (e) {
      print(e.toString());
      return false; // Handle errors gracefully
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z]+\.[a-zA-Z]+$');
    return emailRegex.hasMatch(email);
  }

  // Register button pressed
  void register() async {
    // Prepare info
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String pw = pwController.text.trim();
    final String confirmPw = confirmPwController.text.trim();
    final String username = usernameController.text.trim();

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
      // Check if passwords match
      if (pw != confirmPw) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }

      // Validate email format
      if (!isValidEmail(email)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid email format")));
        return;
      }

      // Validate username format
      if (!isValidUsername(username)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid username. Only letters, numbers, and underscores are allowed.",
            ),
          ),
        );
        return;
      }

      // Check if email is already used
      if (await isEmailUsed(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email is already in use")),
        );
        return;
      }

      // Check if username is already taken
      if (await isUsernameTaken(username)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username is already taken")),
        );
        return;
      }

      // Call register if validations pass
      try {
        await authCubit.register(name, email, pw, username);
        // Optionally, you can navigate to another page or show a success message here
      } catch (e) {
        // Handle registration errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())), // Show the error message
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    pwController.dispose();
    emailController.dispose();
    confirmPwController.dispose();
    usernameController.dispose(); // Dispose username controller
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          // Show Snackbar with error message
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is Authenticated) {
          // Navigate to the next page or show success message
          // For example, you might want to navigate to a home page
          // Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        // Set background color to secondary
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset("assets/logo_color.png", height: 250),
                  const SizedBox(height: 20),

                  // Welcome Message
                  Text(
                    "Let's create an account for you",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Name TextField
                  MyTextField(
                    controller: nameController,
                    hintText: "Name",
                    obscureText: false,
                  ),

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.only(right: 55),
                    child: Text(
                      "* Note username cannot be changed once chosen",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // Username TextField
                  MyTextField(
                    controller: usernameController,
                    hintText: "Username",
                    obscureText: false,
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

                  // Confirm Password TextField
                  MyTextField(
                    controller: confirmPwController,
                    hintText: "Confirm Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),

                  // Register Button
                  MyButton(onTap: register, text: "Register"),
                  const SizedBox(height: 25),

                  // Already a Member? Link
                  RichText(
                    text: TextSpan(
                      text: "Already a member? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      children: [
                        TextSpan(
                          text: "Login now",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }
}
