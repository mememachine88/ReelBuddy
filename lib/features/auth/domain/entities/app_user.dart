class AppUser {
  final String uid;
  final String email;
  final String name;
  final DateTime? createdAt; // Optional field for timestamp

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.createdAt,
  });

  // Convert AppUser -> JSON
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "createdAt":
          createdAt?.toIso8601String(), // Convert DateTime to string for JSON
    };
  }

  // Convert JSON -> AppUser
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser["uid"],
      email: jsonUser["email"],
      name: jsonUser["name"],
      createdAt:
          jsonUser["createdAt"] != null
              ? DateTime.parse(jsonUser["createdAt"])
              : null, // Parse timestamp if it exists
    );
  }
}
