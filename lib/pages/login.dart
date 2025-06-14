import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Content/bottom_nav.dart';
import 'package:foody_zidio/pages/signup.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/widget/widget_support.dart';
import 'package:lottie/lottie.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  bool isTapped = false;
  bool isLoading = false;
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final LocalCacheService _cacheService = LocalCacheService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        String timestamp = DateTime.now().toIso8601String();
        Map<String, dynamic>? userData =
            await _databaseMethods.getUserDetails(user.uid);
        if (userData != null) {
          await _databaseMethods.updateUserLoginTimestamp(user.uid, timestamp);
          await _cacheService.saveUserData(
            id: user.uid,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            wallet: userData['Wallet'] ?? '0',
            profile: userData['profile'] ?? '',
            lastLoginTimestamp: timestamp,
          );
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text(
              "Logged In Successfully",
              style: TextStyle(fontSize: 20.0),
            ),
          ));
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const BottomNav()));
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          message,
          style: const TextStyle(fontSize: 20.0),
        ),
      ));
    } catch (e) {
      print('Error logging in: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 8, 8, 8),
                          Color.fromARGB(255, 5, 5, 5),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: const Text(""),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                    child: Column(
                      children: [
                        Center(
                          child: Image.asset(
                            "images/logo.png",
                            width: MediaQuery.of(context).size.width / 1.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const SizedBox(height: 30.0),
                                  Text(
                                    "Log In",
                                    style: AppWidget.HeadlineText1FeildStyle(),
                                  ),
                                  const SizedBox(height: 30.0),
                                  TextFormField(
                                    controller: userEmailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                      prefixIcon: const Icon(Icons.email_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 30.0),
                                  TextFormField(
                                    controller: userPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Password';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                      prefixIcon: const Icon(Icons.lock),
                                    ),
                                  ),
                                  const SizedBox(height: 80.0),
                                  GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          email = userEmailController.text;
                                          password = userPasswordController.text;
                                        });
                                        login();
                                      }
                                    },
                                    onTapDown: (_) {
                                      setState(() {
                                        isTapped = true;
                                      });
                                    },
                                    onTapUp: (_) {
                                      setState(() {
                                        isTapped = false;
                                      });
                                    },
                                    onTapCancel: () {
                                      setState(() {
                                        isTapped = false;
                                      });
                                    },
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.circular(20),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 15.0),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color:
                                              isTapped ? Colors.grey[400] : Colors.grey,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "LOG IN",
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
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const SignUp()));
                                    },
                                    child: Text(
                                      "Don't have an account? Sign Up",
                                      style: AppWidget.semiBoldTextFeildStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Lottie.asset(
                  'images/Loder_foody.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}