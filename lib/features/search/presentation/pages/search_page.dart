import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/profile/presentation/components/user_tile.dart';
import 'package:fyp/features/search/presentation/cubits/search_cubit.dart';
import 'package:fyp/features/search/presentation/cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    //Scaffold widget
    return Scaffold(
      //AppBar widget
      appBar: AppBar(
        centerTitle: true,
        //seearch text field
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),

      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          //loaded
          //no users
          if (state is SearchLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user!);
              },
            );
          }
          // no users
          //loading
          else if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          //error
          else if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          // default case
          return const Center(child: Text("Start searching for users"));
        },
      ),
    );
  }
}
