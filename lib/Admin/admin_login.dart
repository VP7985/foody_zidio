import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Admin/admin_home.dart';
import 'package:foody_zidio/services/local_cache.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final LocalCacheService _cacheService = LocalCacheService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back to Onboard
      child: Scaffold(
        backgroundColor: const Color(0xFFededeb),
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
              padding: const EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 53, 51, 51), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(300, 110.0),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 60.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Let's start with\nAdmin!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 50.0),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 20.0, top: 5.0, bottom: 5.0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 160, 160, 147)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                controller: usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Username';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Username",
                                  hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 160, 160, 147)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 20.0, top: 5.0, bottom: 5.0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 160, 160, 147)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 160, 160, 147)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  loginAdmin();
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Future<void> loginAdmin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("Admin").get();
      bool isAuthenticated = false;
      String? adminId;
      for (var result in snapshot.docs) {
        if (result.data() != null &&
            result['id'] == usernameController.text.trim() &&
            result['password'] == passwordController.text.trim()) {
          isAuthenticated = true;
          adminId = result['id'];
          break;
        }
      }
      if (isAuthenticated && adminId != null) {
        await _cacheService.saveUserData(
          id: 'admin', // Use fixed ID for admin
          name: adminId,
          email: '',
          wallet: '0',
          profile: '',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdmin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Invalid username or password",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    } catch (e) {
      print('Error logging in admin: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Error: $e",
          style: const TextStyle(fontSize: 18.0),
        ),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}