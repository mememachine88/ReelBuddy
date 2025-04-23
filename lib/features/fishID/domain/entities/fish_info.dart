class FishInfo {
  final String commonName;
  final String scientificName;
  final String conservationStatus;

  FishInfo({
    required this.commonName,
    required this.scientificName,
    required this.conservationStatus,
  });

  factory FishInfo.fromJson(Map<String, dynamic> json) {
    return FishInfo(
      commonName: json['common_name'],
      scientificName: json['scientific_name'],
      conservationStatus: json['conservation_status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'common_name': commonName,
      'scientific_name': scientificName,
      'conservation_status': conservationStatus,
    };
  }
}
