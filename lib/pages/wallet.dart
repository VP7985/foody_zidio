import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:foody_zidio/services/app_constraint.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/services/widget_support.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String walletBalance = "0";
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final LocalCacheService _cacheService = LocalCacheService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        Map<String, String>? cachedData = await _cacheService.getUserData(uid);
        if (cachedData != null && _cacheService.isCacheValid(cachedData)) {
          setState(() {
            walletBalance = cachedData['wallet'] ?? '0';
          });
        } else {
          Map<String, dynamic>? userData = await _databaseMethods.getUserDetails(uid);
          if (userData != null) {
            setState(() {
              walletBalance = userData['Wallet'] ?? '0';
            });
            await _cacheService.updateUserData(id: uid, wallet: walletBalance);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Error loading wallet: $e", style: const TextStyle(fontSize: 20.0,color: Color.fromARGB(70, 156, 149, 149)),
              
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _makePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String amount = amountController.text.trim();
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': '${int.parse(amount) * 100}',
          'currency': 'INR',
          'payment_method_types[]': 'card',
        },
      );
      var json = jsonDecode(response.body);
      if (json['error'] != null) {
        throw Exception(json['error']['message']);
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: json['client_secret'],
          merchantDisplayName: 'Foody Zidio',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        int currentBalance = int.parse(walletBalance);
        int newBalance = currentBalance + int.parse(amount);
        await _databaseMethods.updateUserWallet(uid, newBalance.toString());
        await _cacheService.updateUserData(id: uid, wallet: newBalance.toString());
        setState(() {
          walletBalance = newBalance.toString();
          amountController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text("Wallet topped up successfully!", style: TextStyle(fontSize: 20.0,color: Color.fromARGB(70, 156, 149, 149))),
            ),
          );
        }
      }
    } catch (e) {
      print('Error processing payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Payment failed: $e",
              style: const TextStyle(
              fontSize: 20.0,
              color: Color.fromARGB(70, 156, 149, 149),
              ),
            ),
            ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Wallet", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      "images/wallet.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Current Balance: ₹$walletBalance",
                    style: AppWidget.HeadlineTextFeildStyle(),
                  ),
                  const SizedBox(height: 40.0),
                  Text(
                    "Add Money to Wallet",
                    style: AppWidget.semiBoldWhiteTextFeildStyle(),
                  ),
                  const SizedBox(height: 10.0),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white), // Fix: Set text color to white
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        int? amount = int.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        hintStyle: AppWidget.semiBoldTextFeildStyle(),
                        filled: true,
                        fillColor: Colors.grey[800], // Background for input field
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                          color: Colors.white70, // Fix: Set icon color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  GestureDetector(
                    onTap: _makePayment,
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
                            "Add Money",
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
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}