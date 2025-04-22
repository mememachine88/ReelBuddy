import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fyp/app.dart';
import 'package:fyp/config/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp/utils/fish_species_loader.dart';

List<String> globalFishSpeciesList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final file = File('.env');
  final exists = await file.exists();
  globalFishSpeciesList = await loadFishSpecies();

  print('File exists: $exists');

  if (exists) {
    final content = await file.readAsString();
    print('File content:\n$content');
  }

  try {
    await dotenv.load(fileName: '.env');
    print("✔ .env loaded successfully");
    print("GOOGLE_API_KEY: ${dotenv.env['GOOGLE_API_KEY']}");
  } catch (e) {
    print("❌ Failed to load .env: $e");
  }

  // Step 2: Initialize Firebase
  await Firebase.initializeApp(
    name: 'final-year-project-6936a',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //  Step 3: Activate App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  //  Step 4: Run the app
  runApp(MyApp());
}
