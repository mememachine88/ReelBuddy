// fishID/domain/repo/scan_repo.dart

import '../entities/scan_result.dart';

abstract class ScanRepo {
  Future<void> saveScan(String uid, ScanResult result);
  Future<List<ScanResult>> fetchUserScans(String uid);
}
