import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/logbook/presentation/components/log_tile.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_cubit.dart';
import 'package:fyp/features/logbook/presentation/cubits/logbook_state.dart';
import 'package:fyp/features/logbook/presentation/pages/add_logbook_page.dart';
import 'package:fyp/features/logbook/presentation/pages/stats_page.dart';

class JournalPage extends StatefulWidget {
  final String uid;

  const JournalPage({super.key, required this.uid});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
    context.read<LogbookCubit>().loadEntries(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Journal"),
        backgroundColor: Colors.black,
      ),

      // 🔥 Floating add button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCatchPage(uid: widget.uid)),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🧭 Custom bottom app bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.grey[900],
        notchMargin: 6.0,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Left side empty
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                onPressed: () {
                  final state = context.read<LogbookCubit>().state;
                  if (state is LogbookLoaded) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatsPage(entries: state.entries),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Entries still loading")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),

      // 🐟 Logbook entries
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
                    // optional: navigate to CatchDetailsPage
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
    );
  }
}
