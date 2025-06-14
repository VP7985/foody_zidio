import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Content/onboard.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/widget/widget_support.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final LocalCacheService _cacheService = LocalCacheService();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      Map<String, String>? cachedData =
          await _cacheService.getUserData(currentUser.uid);
      if (cachedData != null && _cacheService.isCacheValid(cachedData)) {
        setState(() {
          nameController.text = cachedData['name'] ?? '';
          emailController.text = cachedData['email'] ?? '';
        });
      } else {
        Map<String, dynamic>? userData =
            await _databaseMethods.getUserDetails(currentUser.uid);
        if (userData != null) {
          String timestamp = DateTime.now().toIso8601String();
          await _databaseMethods.updateUserLoginTimestamp(currentUser.uid, timestamp);
          await _cacheService.saveUserData(
            id: currentUser.uid,
            name: userData['Name'] ?? '',
            email: userData['Email'] ?? '',
            wallet: userData['Wallet'] ?? '0',
            profile: userData['ProfileImageUrl'] ?? '',
            lastLoginTimestamp: timestamp,
          );
          setState(() {
            nameController.text = userData['Name'] ?? '';
            emailController.text = userData['Email'] ?? '';
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _databaseMethods.updateUserProfile(
        currentUser.uid,
        nameController.text as Map<String, dynamic>,
        emailController.text,
        
      );
      await _cacheService.updateUserData(
        id: currentUser.uid,
        name: nameController.text,
        email: emailController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text("Profile updated successfully!"),
      ));
    }
  }

  Future<void> _signOut() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _cacheService.clearUserData(currentUser.uid);
      await _databaseMethods.updateUserLoginTimestamp(currentUser.uid, '');
    }
    await _auth.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Onboard(cacheService: _cacheService),
        ),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Profile",
              style: AppWidget.semiBoldWhiteTextFeildStyle(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
    );
  }
}