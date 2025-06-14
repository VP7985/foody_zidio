import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(userInfoMap);
      // Also add to User_data collection for consistency
      await FirebaseFirestore.instance
          .collection("User_data")
          .doc(userId)
          .set({
        "name": userInfoMap["Name"],
        "LastLoginTimestamp": userInfoMap["LastLoginTimestamp"],
      });
    } catch (e) {
      print('Error adding user details to Firestore: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error fetching user details from Firestore: $e');
      return null;
    }
  }

  Future updateUserWallet(String userId, String wallet) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"Wallet": wallet});
    } catch (e) {
      print('Error updating user wallet in Firestore: $e');
    }
  }

  Future updateUserProfile(String userId, Map<String, dynamic> userInfoMap, String text) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(userInfoMap);
      await FirebaseFirestore.instance
          .collection("User_data")
          .doc(userId)
          .update({"name": userInfoMap["name"] ?? ""});
    } catch (e) {
      print('Error updating user profile in Firestore: $e');
    }
  }

  Future updateUserLoginTimestamp(String userId, String timestamp) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"LastLoginTimestamp": timestamp});
      await FirebaseFirestore.instance
          .collection("User_data")
          .doc(userId)
          .update({"LastLoginTimestamp": timestamp});
    } catch (e) {
      print('Error updating login timestamp in Firestore: $e');
    }
  }

  Future addFoodItem(Map<String, dynamic> addItem, String addId) async {
    try {
      await FirebaseFirestore.instance
          .collection("foodItems")
          .doc(addId)
          .set(addItem);
    } catch (e) {
      print('Error adding food item to Firestore: $e');
    }
  }
}