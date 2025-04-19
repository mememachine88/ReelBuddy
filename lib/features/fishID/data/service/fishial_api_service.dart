// fishID/data/fishial_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FishialApiService {
  final String clientId;
  final String clientSecret;

  FishialApiService()
    : clientId = dotenv.env['FISHIAL_CLIENT_ID']!,
      clientSecret = dotenv.env['FISHIAL_CLIENT_SECRET']!;

  String? _accessToken;

  // 🔑 1. Get Access Token
  Future<String?> getAccessToken() async {
    final response = await http.post(
      Uri.parse("https://api-users.fishial.ai/v1/auth/token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"client_id": clientId, "client_secret": clientSecret}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['access_token'];
      _accessToken = token;
      return token;
    } else {
      print("❌ Failed to fetch access token: ${response.body}");
      return null;
    }
  }

  // 📄 2. Generate File Metadata
  Future<Map<String, dynamic>> getFileMetadata(File file) async {
    final bytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final byteSize = bytes.length;
    final checksum = base64.encode(md5.convert(bytes).bytes);

    return {
      "fileName": fileName,
      "mimeType": mimeType,
      "byteSize": byteSize,
      "checksum": checksum,
      "bytes": bytes,
    };
  }

  // 🔗 3. Get Upload URL
  Future<Map<String, dynamic>?> requestUploadUrl({
    required String fileName,
    required String mimeType,
    required int byteSize,
    required String checksum,
  }) async {
    if (_accessToken == null) return null;

    final response = await http.post(
      Uri.parse("https://api.fishial.ai/v1/recognition/upload"),
      headers: {
        "Authorization": "Bearer $_accessToken",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "blob": {
          "filename": fileName,
          "content_type": mimeType,
          "byte_size": byteSize,
          "checksum": checksum,
        },
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Upload URL request failed: ${response.body}");
      return null;
    }
  }

  // ☁️ 4. Upload Image
  Future<bool> uploadImageToUrl({
    required String uploadUrl,
    required Map<String, String> headers,
    required List<int> bytes,
  }) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: headers,
      body: bytes,
    );
    return response.statusCode == 200;
  }

  // 🧠 5. Perform Fish Detection
  Future<Map<String, dynamic>?> predictFish({required String signedId}) async {
    if (_accessToken == null) return null;

    final response = await http.get(
      Uri.parse("https://api.fishial.ai/v1/recognition/image?q=$signedId"),
      headers: {"Authorization": "Bearer $_accessToken"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Prediction failed: ${response.body}");
      return null;
    }
  }
}
