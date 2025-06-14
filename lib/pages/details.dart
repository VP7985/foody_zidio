import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/widget/widget_support.dart';

class Details extends StatefulWidget {
  final String name, image, detail, price;

  const Details({
    Key? key,
    required this.name,
    required this.image,
    required this.detail,
    required this.price,
  }) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int quantity = 1;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final LocalCacheService _cacheService = LocalCacheService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToCart() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String total = (int.parse(widget.price) * quantity).toString();
      Map<String, dynamic> cartItem = {
        "Name": widget.name,
        "Image": widget.image,
        "Quantity": quantity,
        "Total": total,
        "Timestamp": Timestamp.now(),
      };
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('payment_history')
            .add(cartItem);
        Map<String, String>? cachedData =
            await _cacheService.getUserData(user.uid);
        if (cachedData != null) {
          int currentWallet = int.parse(cachedData['wallet'] ?? '0');
          int newWallet = currentWallet - int.parse(total);
          if (newWallet >= 0) {
            await _databaseMethods.updateUserWallet(user.uid, newWallet.toString());
            await _cacheService.updateUserData(
                id: user.uid, wallet: newWallet.toString());
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text(
                "Item added to cart!",
                style: TextStyle(fontSize: 20.0),
              ),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                "Insufficient wallet balance!",
                style: TextStyle(fontSize: 20.0),
              ),
            ));
          }
        }
      } catch (e) {
        print('Error adding to cart: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Failed to add item: $e",
            style: const TextStyle(fontSize: 20.0),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: Text(widget.name, style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                widget.name,
                style: AppWidget.HeadlineTextFeildStyle(),
              ),
              const SizedBox(height: 10.0),
              Text(
                "₹${widget.price}",
                style: AppWidget.semiBoldWhiteTextFeildStyle(),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.detail,
                style: AppWidget.LightTextFeildStyle(),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Text(
                    "Quantity:",
                    style: AppWidget.semiBoldWhiteTextFeildStyle(),
                  ),
                  const SizedBox(width: 10.0),
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  Text(
                    quantity.toString(),
                    style: AppWidget.semiBoldWhiteTextFeildStyle(),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 40.0),
              GestureDetector(
                onTap: addToCart,
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18.0,
                          fontFamily: 'Poppins1',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}