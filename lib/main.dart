import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:foody_zidio/Content/onboard.dart';
import 'package:foody_zidio/services/app_constraint.dart';
import 'package:foody_zidio/services/local_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = publishableKey;
  final LocalCacheService cacheService = LocalCacheService();
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
      ),
      home: Onboard(cacheService: cacheService),
    );
  }
}