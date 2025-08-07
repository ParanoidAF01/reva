import 'package:flutter/material.dart';
import 'user_profile.dart';
import '../services/service_manager.dart';

class ProfileProvider extends ChangeNotifier {
  String viewedUserId = '';

  void updateProfileData(Map<String, dynamic> profileData) {
    _profile = UserProfile(
      name: profileData['fullName'] ?? _profile.name,
      location: profileData['location'] ?? _profile.location,
      experience: profileData['experience'] ?? _profile.experience,
      languages: profileData['language'] ?? _profile.languages,
      phone: profileData['mobileNumber'] ?? _profile.phone,
      email: profileData['email'] ?? _profile.email,
      avatarPath: profileData['avatar'] ?? _profile.avatarPath,
      totalConnections: profileData['totalConnections'] ?? _profile.totalConnections,
      eventsAttended: profileData['eventsAttended'] ?? _profile.eventsAttended,
    );
    notifyListeners();
  }

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

  // Load profile from API
  Future<void> loadProfile() async {
    try {
      final response = await ServiceManager.instance.profile.getMyProfile();
      if (response['success'] == true && response['data'] != null) {
        final profileData = response['data'];
        _profile = UserProfile(
          name: profileData['fullName'] ?? _profile.name,
          location: profileData['location'] ?? _profile.location,
          experience: profileData['experience'] ?? _profile.experience,
          languages: profileData['language'] ?? _profile.languages,
          phone: profileData['mobileNumber'] ?? _profile.phone,
          email: profileData['email'] ?? _profile.email,
          avatarPath: profileData['avatar'] ?? _profile.avatarPath,
          totalConnections: profileData['totalConnections'] ?? _profile.totalConnections,
          eventsAttended: profileData['eventsAttended'] ?? _profile.eventsAttended,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  // Update profile via API
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final response = await ServiceManager.instance.profile.updateProfile({
        'fullName': profile.name,
        'location': profile.location,
        'experience': profile.experience,
        'language': profile.languages,
        'mobileNumber': profile.phone,
        'email': profile.email,
        'avatar': profile.avatarPath,
      });

      if (response['success'] == true) {
        _profile = profile;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
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
