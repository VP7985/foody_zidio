import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFeildStyle() {
    return const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins');
  }

  static TextStyle HeadlineTextFeildStyle() {
    return const TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins');
  }

  static TextStyle LightTextFeildStyle() {
    return const TextStyle(
        color: Colors.white70,
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins');
  }

  static TextStyle semiBoldWhiteTextFeildStyle() {
    return const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins');
  }

  static TextStyle semiBoldWhite1TextFeildStyle() {
    return const TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins');
  }
}