// fishID/domain/entities/scan_result.dart

class ScanResult {
  final String id;
  final String imageUrl;
  final String speciesName;
  final double confidence;
  final DateTime timestamp;
  final String commonName;

  ScanResult({
    required this.id,
    required this.imageUrl,
    required this.speciesName,
    required this.confidence,
    required this.timestamp,
    required this.commonName,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "imageUrl": imageUrl,
    "speciesName": speciesName,
    "confidence": confidence,
    "timestamp": timestamp.toIso8601String(),
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    id: json["id"],
    imageUrl: json["imageUrl"],
    speciesName: json["speciesName"],
    confidence: (json["confidence"] ?? 0).toDouble(),
    timestamp: DateTime.parse(json["timestamp"]),
    commonName: json["commonName"],
  );
}
