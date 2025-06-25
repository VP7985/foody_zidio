import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(userInfoMap);
      await FirebaseFirestore.instance
          .collection("User_data")
          .doc(userId)
          .set({
        "name": userInfoMap["Name"],
      });
    } catch (e) {
      print('Error adding user details to Firestore: $e');
      rethrow;
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
      rethrow;
    }
  }

  Future updateUserProfile(String userId, Map<String, dynamic> userInfoMap) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(userInfoMap);
      await FirebaseFirestore.instance
          .collection("User_data")
          .doc(userId)
          .update({"name": userInfoMap["Name"] ?? ""});
    } catch (e) {
      print('Error updating user profile in Firestore: $e');
      rethrow;
    }
  }

  Future addFoodItem(Map<String, dynamic> addItem, String category) async {
    try {
      String addId = FirebaseFirestore.instance.collection("foodItems").doc().id;
      await FirebaseFirestore.instance
          .collection("foodItems")
          .doc(addId)
          .set({...addItem, "Category": category});
    } catch (e) {
      print('Error adding food item to Firestore: $e');
      rethrow;
    }
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String userId) async {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("foodCart")
          .snapshots();
    } catch (e) {
      print('Error fetching food cart from Firestore: $e');
      rethrow;
    }
  }

  Future deleteCartItem(String userId, String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("foodCart")
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error deleting cart item from Firestore: $e');
      rethrow;
    }
  }

  Future addFoodToCart(String userId, Map<String, dynamic> cartItem) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("foodCart")
          .add(cartItem);
    } catch (e) {
      print('Error adding food to cart in Firestore: $e');
      rethrow;
    }
  }
}