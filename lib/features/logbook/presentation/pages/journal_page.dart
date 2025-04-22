import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/home/presentation/pages/home_page.dart';
import 'package:fyp/features/home/presentation/pages/main_navigation_page.dart';
import 'package:fyp/features/logbook/presentation/components/bottom_app_bar.dart';
import 'package:fyp/features/logbook/presentation/components/log_tile.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_cubit.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_state.dart';
import 'package:fyp/features/logbook/presentation/pages/add_logbook_page.dart';
import 'package:fyp/features/logbook/presentation/pages/catch_details_page.dart';
import 'package:fyp/features/logbook/presentation/pages/show_all_fishing_spot.dart';
import 'package:fyp/features/logbook/presentation/pages/stats_page.dart';

class JournalPage extends StatefulWidget {
  final String uid;

  const JournalPage({super.key, required this.uid});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  int selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    context.read<LogbookCubit>().loadEntries(widget.uid);
  }

  void _handleNavTap(int index) {
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    final state = context.read<LogbookCubit>().state;

    switch (index) {
      case 0: //Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        );

        break;
      case 1: // Map
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShowAllFishingSpot()),
        );
        break;
      case 2: //Stats
        if (state is LogbookLoaded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatsPage(entries: state.entries),
            ),
          );
        }
        break;
      case 3: //Journal
        // Already on this page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journal")),

      body: BlocBuilder<LogbookCubit, LogbookState>(
        builder: (context, state) {
          if (state is LogbookLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LogbookLoaded) {
            final entries = state.entries;
            if (entries.isEmpty) {
              return const Center(
                child: Text(
                  "No catches yet.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return LogbookTile(
                  entry: entry,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CatchDetailsPage(entry: entry),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is LogbookError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          return const SizedBox();
        },
      ),

      bottomNavigationBar: FloatingBottomAppBar(
        activeIndex: selectedIndex,
        onItemSelected: _handleNavTap,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCatchPage(uid: widget.uid)),
          );
        },
      ),
    );
  }
}
