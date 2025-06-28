import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:foody_zidio/Content/bottom_nav.dart';
import 'package:foody_zidio/Content/onboard.dart';
import 'package:foody_zidio/services/app_constraint.dart';
import 'package:foody_zidio/services/local_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final LocalCacheService cacheService = LocalCacheService();
  Stripe.publishableKey = publishableKey;
  await cacheService.init();
  runApp(MyApp(cacheService: cacheService));
}

class MyApp extends StatelessWidget {
  final LocalCacheService cacheService;

  const MyApp({Key? key, required this.cacheService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foody Zidio',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: AuthWrapper(cacheService: cacheService),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final LocalCacheService cacheService;

  const AuthWrapper({Key? key, required this.cacheService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return BottomNav(); 
        }
        return Onboard(cacheService: cacheService); 
      },
    );
  }
}