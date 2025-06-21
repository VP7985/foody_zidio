import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/pages/login.dart';
import 'package:foody_zidio/services/user_async_activity.dart';
import 'package:foody_zidio/services/widget_support.dart';
import 'package:foody_zidio/services/widget_support.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserSyncService _userSyncService = UserSyncService();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  TextEditingController profileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        Map<String, dynamic>? userData = await _userSyncService.getUserData(currentUser.uid);
        if (userData != null) {
          setState(() {
            nameController.text = userData['Name'] ?? '';
            emailController.text = userData['Email'] ?? '';
            walletController.text = userData['Wallet'] ?? '0';
            profileController.text = userData['Profile'] ?? '';
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Error loading user data: $e", style: const TextStyle(fontSize: 20.0)),
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _userSyncService.syncUserData(currentUser.uid, emailController.text.trim());  
        await _userSyncService.storeUserData(
          userId: currentUser.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          wallet: walletController.text.trim(),
          profile: profileController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text("Profile updated successfully!", style: TextStyle(fontSize: 20.0)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Error updating profile: $e", style: const TextStyle(fontSize: 20.0)),
            ),
          );
        }
      }
    }
  }

  Future<void> _signOut() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _userSyncService.clearAllUserData();
        await _auth.signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LogIn()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Error signing out: $e", style: const TextStyle(fontSize: 20.0)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Settings", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Update Profile",
                        style: AppWidget.semiBoldWhiteTextFeildStyle(),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: AppWidget.semiBoldTextFeildStyle(),
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: AppWidget.semiBoldTextFeildStyle(),
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: TextFormField(
                          controller: walletController,
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter wallet balance';
                            }
                            if (int.tryParse(value) == null || int.parse(value) < 0) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Wallet Balance",
                            labelStyle: AppWidget.semiBoldTextFeildStyle(),
                            prefixIcon: const Icon(Icons.account_balance_wallet),
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: TextFormField(
                          controller: profileController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Profile Image URL (Optional)",
                            labelStyle: AppWidget.semiBoldTextFeildStyle(),
                            prefixIcon: const Icon(Icons.image),
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _updateProfile,
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
                                "Update Profile",
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
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _signOut,
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                "Sign Out",
                                style: TextStyle(
                                  color: Colors.white,
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
            ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    walletController.dispose();
    profileController.dispose();
    super.dispose();
  }
}