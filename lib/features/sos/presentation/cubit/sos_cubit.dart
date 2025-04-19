import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';
import 'package:fyp/features/sos/domain/repo/sos_repo.dart';

import 'sos_state.dart';

class SOSCubit extends Cubit<SOSState> {
  final SOSRepo sosRepo;

  SOSCubit(this.sosRepo) : super(SOSInitial());

  Future<void> sendSOS(SOSAlert alert, List<String> followerUids) async {
    print("🔥 sendSOS called");
    print("👉 Followers: $followerUids");
    print("🧾 Alert Data: ${alert.toJson()}");

    try {
      emit(SOSLoading());
      await sosRepo.sendSOSAlert(alert, followerUids);
      emit(SOSSuccess());
      print("✅ SOS sent successfully");
    } catch (e) {
      print("❌ SOS send error: $e");
      emit(SOSError(e.toString()));
    }
  }

  Future<void> loadReceivedAlerts(String currentUid) async {
    try {
      emit(SOSLoading());
      final alerts = await sosRepo.fetchReceivedAlerts(currentUid);
      emit(SOSLoaded(alerts));
    } catch (e) {
      emit(SOSError(e.toString()));
    }
  }
}
