// fishID/presentation/cubits/scan_cubit.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/service/fishial_api_service.dart';
import '../../data/firebase_scan_repo.dart';
import '../../domain/entities/scan_result.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final FishialApiService fishialApi;
  final FirebaseScanRepo firebaseRepo;

  ScanCubit({required this.fishialApi, required this.firebaseRepo})
    : super(ScanInitial());

  Future<void> scanFish(File imageFile, String uid) async {
    try {
      emit(ScanLoading());

      await fishialApi.getAccessToken();
      final meta = await fishialApi.getFileMetadata(imageFile);
      final uploadInfo = await fishialApi.requestUploadUrl(
        fileName: meta['fileName'],
        mimeType: meta['mimeType'],
        byteSize: meta['byteSize'],
        checksum: meta['checksum'],
      );

      final uploadUrl = uploadInfo?["direct-upload"]?["url"];
      final signedId = uploadInfo?["signed-id"];
      final headers = Map<String, String>.from(
        uploadInfo?["direct-upload"]?["headers"] ?? {},
      );

      if (uploadUrl == null || signedId == null)
        throw Exception("Missing upload info");

      final uploaded = await fishialApi.uploadImageToUrl(
        uploadUrl: uploadUrl,
        headers: headers,
        bytes: meta['bytes'],
      );

      if (!uploaded) throw Exception("Upload failed");

      final resultJson = await fishialApi.predictFish(signedId: signedId);
      final species = resultJson?["results"]?[0]?["species"]?[0];

      final String scientificName = species["name"];
      final String commonName =
          species["fishangler-data"]?["common_name"] ?? scientificName;

      if (species == null) throw Exception("No species detected");

      final result = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageFile.path,
        speciesName: commonName, // ✅ use common name if available
        confidence: (species["accuracy"] as num).toDouble(),
        timestamp: DateTime.now(),
      );

      await firebaseRepo.saveScan(uid, result);

      emit(ScanSuccess(result));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  void reset() {
    emit(ScanInitial());
  }
}
