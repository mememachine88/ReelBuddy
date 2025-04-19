// lib/features/sos/domain/repo/sos_repo.dart
import 'package:fyp/features/sos/domain/entities/sos.dart';

abstract class SOSRepo {
  Future<void> sendSOSAlert(SOSAlert alert, List<String> followerUids);
  Future<List<SOSAlert>> fetchReceivedAlerts(String currentUid);
}
