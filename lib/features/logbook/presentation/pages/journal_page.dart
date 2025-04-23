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
import 'package:loading_animation_widget/loading_animation_widget.dart';

class JournalPage extends StatefulWidget {
  final String uid;

  const JournalPage({super.key, required this.uid});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  int selectedIndex = 3;
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Load entries only once
    context.read<LogbookCubit>().loadEntries(widget.uid);
    selectedIndex = 3;
  }

  Future<void> _handleNavTap(int index) async {
    if (index == selectedIndex || isNavigating) return;

    setState(() {
      isNavigating = true;
    });

    final state = context.read<LogbookCubit>().state;

    try {
      switch (index) {
        case 1: // Map
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShowAllFishingSpot()),
          );
          break;
        case 2: // Stats
          if (state is LogbookLoaded) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatsPage(entries: state.entries),
              ),
            );
          } else {
            // Show a message if stats are accessed before entries are loaded
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please wait for entries to load")),
            );
          }
          break;
      }
    } finally {
      // Reset navigation state when returned
      if (mounted) {
        setState(() {
          isNavigating = false;
          selectedIndex = 3; // Reset to the journal tab
        });
      }
    }
  }

  void _navigateToAddCatch() {
    if (isNavigating) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCatchPage(uid: widget.uid)),
    ).then((_) {
      // Refresh entries when returning from add catch page
      context.read<LogbookCubit>().loadEntries(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'All Your Recent Catches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<LogbookCubit>().loadEntries(widget.uid);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<LogbookCubit, LogbookState>(
            builder: (context, state) {
              if (state is LogbookLoading) {
                return Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 70,
                  ),
                );
              } else if (state is LogbookLoaded) {
                final entries = state.entries;
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No catches yet.",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _navigateToAddCatch,
                          icon: Icon(Icons.add_photo_alternate),
                          label: Text("Add Your First Catch"),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<LogbookCubit>().loadEntries(widget.uid);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                  ),
                );
              } else if (state is LogbookError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LogbookCubit>().loadEntries(widget.uid);
                        },
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          // Overlay loading indicator for navigation
          if (isNavigating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 70,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: FloatingBottomAppBar(
        activeIndex: selectedIndex,
        onItemSelected: _handleNavTap,
        onPressed: _navigateToAddCatch,
      ),
    );
  }
}
