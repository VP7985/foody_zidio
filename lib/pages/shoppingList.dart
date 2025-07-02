import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Data/payment_successfull.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/services/widget_support.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ShoppingList extends StatefulWidget {
  final String userId;

  const ShoppingList({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> with SingleTickerProviderStateMixin {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final LocalCacheService _cacheService = LocalCacheService();
  Stream<QuerySnapshot>? foodCartStream;
  String? wallet;
  int cartTotal = 0;
  late TabController _tabController;
  final GlobalKey<LiquidPullToRefreshState> _refreshKey = GlobalKey<LiquidPullToRefreshState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadData() async {
    try {
      await _cacheService.init();
      Map<String, String>? userData = await _cacheService.getUserData(widget.userId);
      wallet = userData?['wallet'] ?? '0';
      foodCartStream = await _databaseMethods.getFoodCart(widget.userId);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  Future<void> _updateWallet(int newAmount) async {
    try {
      await _databaseMethods.updateUserWallet(widget.userId, newAmount.toString());
      await _cacheService.updateUserData(
        id: widget.userId,
        wallet: newAmount.toString(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating wallet: $e')),
        );
      }
      rethrow;
    }
  }

  Widget _buildCartTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: foodCartStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: AppWidget.LightTextFeildStyle()));
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          Map<String, List<DocumentSnapshot>> groupedItems = {};
          for (var doc in snapshot.data!.docs) {
            String name = doc['Name'];
            groupedItems[name] = groupedItems[name] ?? [];
            groupedItems[name]!.add(doc);
          }

          cartTotal = 0;
          List<Widget> itemWidgets = [];
          groupedItems.forEach((name, docs) {
            int quantity = docs.fold(0, (sum, doc) => sum + int.parse(doc["Quantity"]));
            int itemTotal = docs.fold(0, (sum, doc) => sum + int.parse(doc["Total"].toString()));
            cartTotal += itemTotal;

            itemWidgets.add(
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[800],
                  child: Dismissible(
                    key: Key(docs.first.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      try {
                        await _databaseMethods.deleteCartItem(widget.userId, docs.first.id);
                        if (mounted) {
                          setState(() {
                            cartTotal -= itemTotal;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting item: $e')),
                          );
                        }
                      }
                    },
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      alignment: AlignmentDirectional.centerEnd,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              docs.first["Image"],
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppWidget.semiBoldWhiteTextFeildStyle()),
                                Text("Quantity: $quantity", style: AppWidget.LightTextFeildStyle()),
                                Text("\u{20B9}$itemTotal", style: AppWidget.LightTextFeildStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: itemWidgets,
                ),
              ),
              const Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Price", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("\u{20B9}$cartTotal", style: AppWidget.semiBoldWhiteTextFeildStyle()),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () async {
                  if (cartTotal == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text("Please add items to the cart!", style: TextStyle(fontSize: 20.0)),
                      ),
                    );
                    return;
                  }
                  try {
                    int walletAmount = int.parse(wallet ?? '0');
                    if (walletAmount >= cartTotal) {
                      int newWallet = walletAmount - cartTotal;
                      await _updateWallet(newWallet);
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      for (var doc in snapshot.data!.docs) {
                        DocumentReference historyRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .collection('payment_history')
                            .doc();
                        batch.set(historyRef, {
                          'Name': doc['Name'],
                          'Image': doc['Image'],
                          'Quantity': doc['Quantity'],
                          'Total': doc['Total'],
                          'Timestamp': Timestamp.now(),
                        });
                        DocumentReference cartRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .collection('foodCart')
                            .doc(doc.id);
                        batch.delete(cartRef);
                      }
                      await batch.commit();
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentSuccessfull()),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text("Insufficient funds in wallet!", style: TextStyle(fontSize: 20.0)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Checkout error: $e')),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: const Center(
                    child: Text(
                      "Checkout",
                      style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/empty.png', width: 200, height: 200),
              const SizedBox(height: 20),
              Text("Cart is empty.", style: AppWidget.semiBoldWhiteTextFeildStyle()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('payment_history')
          .orderBy('Timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: AppWidget.LightTextFeildStyle()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/no_data.png', width: 200, height: 200),
                const SizedBox(height: 20),
                Text("No orders found.", style: AppWidget.semiBoldWhiteTextFeildStyle()),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot order = snapshot.data!.docs[index];
            return Card(
              color: Colors.grey[800],
              elevation: 5.0,
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    order['Image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                ),
                title: Text(order['Name'], style: AppWidget.semiBoldWhiteTextFeildStyle()),
                subtitle: Text(
                  'Quantity: ${order['Quantity']} | Total: \u{20B9}${order['Total']}',
                  style: AppWidget.LightTextFeildStyle(),
                ),
                trailing: Text(
                  (order['Timestamp'] as Timestamp).toDate().toString().substring(0, 16),
                  style: AppWidget.LightTextFeildStyle(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("My Orders", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Cart"),
            Tab(text: "Order History"),
          ],
        ),
      ),
      body: LiquidPullToRefresh(
        key: _refreshKey,
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: Colors.white,
        backgroundColor: Colors.black,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCartTab(),
            _buildOrderHistoryTab(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}