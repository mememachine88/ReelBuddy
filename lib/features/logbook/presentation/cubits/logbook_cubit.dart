import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/logbook_entry.dart';
import '../../domain/repo/logbook_repo.dart';
import 'logbook_state.dart';

class LogbookCubit extends Cubit<LogbookState> {
  final LogbookRepo logbookRepo;

  LogbookCubit({required this.logbookRepo}) : super(LogbookInitial());

  Future<void> loadEntries(String uid) async {
    emit(LogbookLoading());
    try {
      final entries = await logbookRepo.fetchEntries(uid);
      emit(LogbookLoaded(entries));
    } catch (e) {
      emit(LogbookError("Failed to load logbook: $e"));
    }
  }
  //Add fiishing Entry

  Future<void> addEntry(LogbookEntry entry) async {
    emit(LogbookSubmitting()); //Emit submitting instead of loading
    try {
      await logbookRepo.addEntry(entry);
      emit(LogbookEntryAdded());
      await loadEntries(
        entry.uid,
      ); // Will trigger LogbookLoading + LogbookLoaded
    } catch (e) {
      emit(LogbookError("Failed to add entry: $e"));
    }
  }

  Future<void> deleteEntry(String id, String uid) async {
    try {
      await logbookRepo.deleteEntry(id);
      await loadEntries(uid);
      emit(LogbookEntryDeleted());
    } catch (e) {
      emit(LogbookError("Failed to delete entry: $e"));
    }
  }
}
