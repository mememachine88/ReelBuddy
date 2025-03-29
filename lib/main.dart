import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase initialization
import 'package:fyp/app.dart';
import 'package:fyp/features/auth/presentation/pages/login_page.dart';
import 'package:fyp/features/auth/presentation/pages/register_page.dart';
import 'package:fyp/config/firebase_options.dart';
import 'package:fyp/themes/light_mode.dart';
import 'package:fyp/features/auth/presentation/pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}
