import '../../domain/entities/logbook_entry.dart';

abstract class LogbookState {}

class LogbookInitial extends LogbookState {}

class LogbookLoading extends LogbookState {}

class LogbookLoaded extends LogbookState {
  final List<LogbookEntry> entries;
  LogbookLoaded(this.entries);
}

class LogbookEntryAdded extends LogbookState {}

class LogbookEntryDeleted extends LogbookState {}

class LogbookError extends LogbookState {
  final String message;
  LogbookError(this.message);
}

class LogbookSubmitting extends LogbookState {}
