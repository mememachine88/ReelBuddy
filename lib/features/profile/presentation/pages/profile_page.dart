import 'package:flutter/material.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/home/presentation/components/my_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubits

  late final AuthCubit = context.read<AuthCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      //Drawer
      drawer: const MyDrawer(),
    );
  }
}
