import '../entities/logbook_entry.dart';

abstract class LogbookRepo {
  Future<void> addEntry(LogbookEntry entry);
  Future<List<LogbookEntry>> fetchEntries(String uid);
  Future<void> deleteEntry(String id);
}
