import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/themes/theme_cubit.dart';
import 'package:app_settings/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    //is dark mode
    bool isDarkMode = themeCubit.isDarkMode;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Dark Mode"),
              trailing: CupertinoSwitch(
                value: isDarkMode,
                onChanged: (value) {
                  themeCubit.toggleTheme();
                },
              ),
            ),
            ListTile(
              title: const Text("Location Permissions"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                AppSettings.openAppSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
