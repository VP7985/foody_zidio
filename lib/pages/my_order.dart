import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/pages/shoppingList.dart';

class Ordered extends StatelessWidget {
  const Ordered({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Please log in to view your orders.",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.grey[900],
      );
    }
    return ShoppingList(userId: userId);
  }
}