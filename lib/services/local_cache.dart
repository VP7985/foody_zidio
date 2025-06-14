import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalCacheService {
  static SharedPreferences? _prefs;
  static const String _userDataKeyPrefix = 'user_data_';
  static const int _cacheValidityDays = 7;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save user data to cache
  Future<void> saveUserData({
    required String id,
    String? name,
    String? email,
    String? wallet,
    String? profile,
    String? lastLoginTimestamp,
  }) async {
    await init();
    final userData = {
      'id': id,
      'name': name ?? '',
      'email': email ?? '',
      'wallet': wallet ?? '0',
      'profile': profile ?? '',
      'lastLoginTimestamp': lastLoginTimestamp ?? DateTime.now().toIso8601String(),
    };
    try {
      await _prefs!.setString(
        '$_userDataKeyPrefix$id',
        jsonEncode(userData),
      );
    } catch (e) {
      print('Error saving user data to cache: $e');
    }
  }

  // Retrieve user ID
  Future<String?> getUserId(String id) async {
    final userData = await getUserData(id);
    return userData?['id'];
  }

  // Retrieve user name
  Future<String?> getUserName(String id) async {
    final userData = await getUserData(id);
    return userData?['name'];
  }

  // Retrieve user email
  Future<String?> getUserEmail(String id) async {
    final userData = await getUserData(id);
    return userData?['email'];
  }

  // Retrieve user wallet
  Future<String?> getUserWallet(String id) async {
    final userData = await getUserData(id);
    return userData?['wallet'];
  }

  // Retrieve user profile image URL
  Future<String?> getUserProfile(String id) async {
    final userData = await getUserData(id);
    return userData?['profile'];
  }

  // Retrieve full user data
  Future<Map<String, String>?> getUserData(String id) async {
    await init();
    try {
      final userDataString = _prefs!.getString('$_userDataKeyPrefix$id');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        return {
          'id': userData['id'] as String,
          'name': userData['name'] as String,
          'email': userData['email'] as String,
          'wallet': userData['wallet'] as String,
          'profile': userData['profile'] as String,
          'lastLoginTimestamp': userData['lastLoginTimestamp'] as String,
        };
      }
    } catch (e) {
      print('Error retrieving user data from cache: $e');
    }
    return null;
  }

  // Update specific user data fields
  Future<void> updateUserData({
    required String id,
    String? name,
    String? email,
    String? wallet,
    String? profile,
    String? lastLoginTimestamp,
  }) async {
    await init();
    final currentData = await getUserData(id);
    final updatedData = {
      'id': id,
      'name': name ?? currentData?['name'] ?? '',
      'email': email ?? currentData?['email'] ?? '',
      'wallet': wallet ?? currentData?['wallet'] ?? '0',
      'profile': profile ?? currentData?['profile'] ?? '',
      'lastLoginTimestamp':
          lastLoginTimestamp ?? currentData?['lastLoginTimestamp'] ?? DateTime.now().toIso8601String(),
    };
    try {
      await _prefs!.setString(
        '$_userDataKeyPrefix$id',
        jsonEncode(updatedData),
      );
    } catch (e) {
      print('Error updating user data in cache: $e');
    }
  }

  // Clear user data from cache
  Future<void> clearUserData(String id) async {
    await init();
    try {
      await _prefs!.remove('$_userDataKeyPrefix$id');
    } catch (e) {
      print('Error clearing user data from cache: $e');
    }
  }

  // Check if cached data is valid (within 7 days)
  bool isCacheValid(Map<String, String>? cachedData) {
    if (cachedData == null) return false;
    final lastLoginTimestamp = cachedData['lastLoginTimestamp'];
    if (lastLoginTimestamp == null || lastLoginTimestamp.isEmpty) {
      return false;
    }
    try {
      final lastLogin = DateTime.parse(lastLoginTimestamp);
      final now = DateTime.now();
      final difference = now.difference(lastLogin).inDays;
      return difference <= _cacheValidityDays;
    } catch (e) {
      print('Error parsing last login timestamp: $e');
      return false;
    }
  }
}