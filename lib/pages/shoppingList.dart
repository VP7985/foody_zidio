import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/widget/widget_support.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ShoppingList extends StatefulWidget {
  final String userId;

  const ShoppingList({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Future<void> _handleRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("My Orders", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: Colors.white,
        backgroundColor: Colors.black,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('payment_history')
              .orderBy('Timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/no_data.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No orders found.",
                      style: AppWidget.semiBoldWhiteTextFeildStyle(),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot order = snapshot.data!.docs[index];
                  return Card(
                    color: Colors.grey[800],
                    elevation: 5.0,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          order['Image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        order['Name'],
                        style: AppWidget.semiBoldWhiteTextFeildStyle(),
                      ),
                      subtitle: Text(
                        'Quantity: ${order['Quantity']} | Total: ₹${order['Total']}',
                        style: AppWidget.LightTextFeildStyle(),
                      ),
                      trailing: Text(
                        (order['Timestamp'] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 16),
                        style: AppWidget.LightTextFeildStyle(),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}