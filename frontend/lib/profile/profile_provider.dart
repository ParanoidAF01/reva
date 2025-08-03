import 'package:flutter/material.dart';
import 'user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile(
    name: 'Abhishek Singh',
    location: 'Delhi NCR',
    experience: '4+ years',
    languages: 'Hindi, English',
    phone: '+91 **********',
    email: 'a*********************',
    avatarPath: 'assets/dummyprofile.png',
    totalConnections: 0,
    eventsAttended: 0,
  );

  UserProfile get profile => _profile;

  void updateProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void editField({
    String? name,
    String? location,
    String? experience,
    String? languages,
    String? phone,
    String? email,
    String? avatarPath,
    int? totalConnections,
    int? eventsAttended,
  }) {
    _profile = _profile.copyWith(
      name: name,
      location: location,
      experience: experience,
      languages: languages,
      phone: phone,
      email: email,
      avatarPath: avatarPath,
      totalConnections: totalConnections,
      eventsAttended: eventsAttended,
    );
    notifyListeners();
  }
}
