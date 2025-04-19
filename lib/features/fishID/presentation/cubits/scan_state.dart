// fishID/presentation/cubits/scan_state.dart

import '../../domain/entities/scan_result.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final ScanResult result;

  ScanSuccess(this.result);
}

class ScanError extends ScanState {
  final String message;

  ScanError(this.message);
}
