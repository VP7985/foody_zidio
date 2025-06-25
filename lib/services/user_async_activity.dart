import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/services/local_cache.dart';

class UserSyncService {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final LocalCacheService _cacheService = LocalCacheService();

  Future<void> storeUserData({
    required String userId,
    required String name,
    required String email,
    String wallet = '0',
    String profile = '',
  }) async {
    try {
      Map<String, dynamic> userData = {
        'Name': name,
        'Email': email,
        'Wallet': wallet,
        'Profile': profile,
      };
      await _databaseMethods.addUserDetail(userData, userId);
      await _cacheService.saveUserData(
        id: userId,
        name: name,
        email: email,
        wallet: wallet,
        profile: profile,
      );
    } catch (e) {
      throw Exception('Failed to store user data: $e');
    }
  }

  Future<void> syncUserData(String userId, String email) async {
    try {
      Map<String, dynamic>? userData = await _databaseMethods.getUserDetails(userId);
      if (userData == null) {
        userData = {
          'Name': 'User',
          'Email': email,
          'Wallet': '0',
          'Profile': '',
        };
        await _databaseMethods.addUserDetail(userData, userId);
      }
      await _cacheService.saveUserData(
        id: userId,
        name: userData['Name'] ?? 'User',
        email: userData['Email'] ?? email,
        wallet: userData['Wallet'] ?? '0',
        profile: userData['Profile'] ?? '',
      );
    } catch (e) {
      throw Exception('Failed to sync user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      Map<String, String>? cachedData = await _cacheService.getUserData(userId);
      if (cachedData != null && _cacheService.isCacheValid(cachedData)) {
        return {
          'Name': cachedData['name'],
          'Email': cachedData['email'],
          'Wallet': cachedData['wallet'],
          'Profile': cachedData['Profile'],
        };
      }
      Map<String, dynamic>? userData = await _databaseMethods.getUserDetails(userId);
      if (userData != null) {
        await _cacheService.saveUserData(
          id: userId,
          name: userData['Name'] ?? '',
          email: userData['Email'] ?? '',
          wallet: userData['Wallet'] ?? '0',
          profile: userData['Profile'] ?? '',
        );
        return userData;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserData({
    required String userId,
    String? name,
    String? email,
    String? wallet,
    String? profile,
  }) async {
    try {
      Map<String, dynamic> userData = {};
      if (name != null) userData['Name'] = name;
      if (email != null) userData['Email'] = email;
      if (wallet != null) userData['Wallet'] = wallet;
      if (profile != null) userData['Profile'] = profile;

      if (userData.isNotEmpty) {
        await _databaseMethods.updateUserProfile(userId, userData);
        await _cacheService.updateUserData(
          id: userId,
          name: name,
          email: email,
          wallet: wallet,
          profile: profile,
        );
      }
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  Future<void> clearUserData(String userId) async {
    try {
      await _cacheService.clearUserData(userId);
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  Future<void> addToCart(String userId, Map<String, dynamic> cartItem) async {
    try {
      await _databaseMethods.addFoodToCart(userId, cartItem);
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Stream<QuerySnapshot> getFoodCart(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("foodCart")
          .snapshots();
    } catch (e) {
      throw Exception('Failed to get food cart: $e');
    }
  }

  Future<void> deleteCartItem(String userId, String itemId) async {
    try {
      await _databaseMethods.deleteCartItem(userId, itemId);
    } catch (e) {
      throw Exception('Failed to delete cart item: $e');
    }
  }
  
}