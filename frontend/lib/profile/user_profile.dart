class UserProfile {
  String name;
  String location;
  String experience;
  String language;
  String phone;
  String email;
  String avatarPath;
  int totalConnections;
  int eventsAttended;

  UserProfile({
    required this.name,
    required this.location,
    required this.experience,
    required this.language,
    required this.phone,
    required this.email,
    required this.avatarPath,
    required this.totalConnections,
    required this.eventsAttended,
  });

  UserProfile copyWith({
    String? name,
    String? location,
    String? experience,
    String? language,
    String? phone,
    String? email,
    String? avatarPath,
    int? totalConnections,
    int? eventsAttended,
  }) {
    return UserProfile(
      name: name ?? this.name,
      location: location ?? this.location,
      experience: experience ?? this.experience,
      language: language ?? this.language,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      totalConnections: totalConnections ?? this.totalConnections,
      eventsAttended: eventsAttended ?? this.eventsAttended,
    );
  }
}
