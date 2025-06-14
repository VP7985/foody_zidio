import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Admin/admin_login.dart';
import 'package:foody_zidio/Content/bottom_nav.dart';
import 'package:foody_zidio/pages/login.dart';
import 'package:foody_zidio/services/local_cache.dart';

class Onboard extends StatefulWidget {
  final LocalCacheService cacheService;

  const Onboard({Key? key, required this.cacheService}) : super(key: key);

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Map<String, String>? userData = await widget.cacheService.getUserData(user.uid);
      if (userData != null && widget.cacheService.isCacheValid(userData)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
        );
      }
    } else {
      String? adminId = await widget.cacheService.getUserId('admin');
      if (adminId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLogin()),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from exiting app
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/logo.png",
                width: MediaQuery.of(context).size.width / 2,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome to Foody Zidio",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogIn()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "User Login",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLogin()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Admin Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
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