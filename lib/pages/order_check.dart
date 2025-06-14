import 'package:flutter/material.dart';
import 'package:foody_zidio/widget/widget_support.dart';

class OrderCheck extends StatelessWidget {
  const OrderCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: Text("Order Confirmation",
            style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Order confirmation page under construction.",
          style: AppWidget.semiBoldWhiteTextFeildStyle(),
        ),
      ),
    );
  }
}