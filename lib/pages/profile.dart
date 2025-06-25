import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Content/onboard.dart';
import 'package:foody_zidio/Content/setting_updt.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/services/widget_support.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "User", email = "", wallet = "0";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalCacheService _cacheService = LocalCacheService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      Map<String, String>? cachedData = await _cacheService.getUserData(uid);
      if (cachedData != null && _cacheService.isCacheValid(cachedData)) {
        setState(() {
          name = cachedData['name'] ?? 'User';
          email = cachedData['email'] ?? '';
          wallet = cachedData['wallet'] ?? '0';
        });
      } else {
        setState(() {
          name = _auth.currentUser?.displayName ?? 'User';
          email = _auth.currentUser?.email ?? '';
        });
      }
    }
  }

  Future<void> _logout() async {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _cacheService.clearUserData(uid);
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Onboard(cacheService: _cacheService),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Profile", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("images/person.png"),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                name,
                style: AppWidget.HeadlineTextFeildStyle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                email,
                style: AppWidget.semiBoldWhiteTextFeildStyle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "Wallet Balance: ₹$wallet",
                style: AppWidget.semiBoldWhiteTextFeildStyle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
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
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: _logout,
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
                        "Logout",
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
    );
  }
}