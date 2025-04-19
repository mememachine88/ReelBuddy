import 'package:equatable/equatable.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';

abstract class SOSState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SOSInitial extends SOSState {}

class SOSLoading extends SOSState {}

class SOSLoaded extends SOSState {
  final List<SOSAlert> alerts;

  SOSLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class SOSSuccess extends SOSState {}

class SOSError extends SOSState {
  final String message;

  SOSError(this.message);

  @override
  List<Object?> get props => [message];
}
