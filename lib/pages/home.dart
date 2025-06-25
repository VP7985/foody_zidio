import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foody_zidio/pages/details.dart';
import 'package:foody_zidio/pages/my_order.dart';
import 'package:foody_zidio/services/user_async_activity.dart';
import 'package:foody_zidio/services/widget_support.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = false, salad = false, burger = false;
  String userName = "User";
  final UserSyncService _userSyncService = UserSyncService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, dynamic>? userData =
            await _userSyncService.getUserData(currentUser.uid);
        if (userData != null) {
          setState(() {
            userName = userData['Name'] ?? 'User';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Error loading user data: $e",
                style: const TextStyle(fontSize: 20.0)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserData();
  }

  List<DocumentSnapshot> getFilteredFoodItems(
      List<DocumentSnapshot> foodItems) {
    if (icecream) {
      return foodItems.where((doc) => doc['Category'] == 'Ice-cream').toList();
    } else if (pizza) {
      return foodItems.where((doc) => doc['Category'] == 'Pizza').toList();
    } else if (salad) {
      return foodItems.where((doc) => doc['Category'] == 'Salad').toList();
    } else if (burger) {
      return foodItems.where((doc) => doc['Category'] == 'Burger').toList();
    } else {
      return foodItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {},
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        title:
            Text("Foody Zidio", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Ordered()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20.0),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              color: Colors.white,
              backgroundColor: Colors.black,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin:
                      const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello $userName🥰",
                          style: AppWidget.semiBoldWhiteTextFeildStyle()),
                      const SizedBox(height: 10.0),
                      Text("Delicious Food",
                          style: AppWidget.HeadlineTextFeildStyle()),
                      Text("Discover and Get Great Food",
                          style: AppWidget.LightTextFeildStyle()),
                      const SizedBox(height: 20.0),
                      showItem(),
                      const SizedBox(height: 30.0),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('foodItems')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'images/no_data.png',
                                    width: 400,
                                    height: 400,
                                  ),
                                  Text(
                                    "Oops ..... \n There is no any type of item are available..",
                                    style:
                                        AppWidget.semiBoldWhiteTextFeildStyle(),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            List<DocumentSnapshot> foodItems =
                                snapshot.data!.docs;
                            return buildListView(foodItems);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildListView(List<DocumentSnapshot> foodItems) {
    List<DocumentSnapshot> filteredFoodItems = getFilteredFoodItems(foodItems);

    List<DocumentSnapshot> burgerPizzaItems = filteredFoodItems
        .where(
            (doc) => doc['Category'] == 'Burger' || doc['Category'] == 'Pizza')
        .toList();

    List<DocumentSnapshot> otherItems = filteredFoodItems
        .where(
            (doc) => doc['Category'] != 'Burger' && doc['Category'] != 'Pizza')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (burgerPizzaItems.isNotEmpty) ...[
          const SizedBox(height: 20.0),
          Text("Burger and Pizza Items",
              style: AppWidget.semiBoldWhiteTextFeildStyle()),
          const SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: burgerPizzaItems.map((foodItem) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          detail: foodItem['Detail'],
                          image: foodItem['Image'],
                          name: foodItem['Name'],
                          price: foodItem['Price'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[800],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Image.network(
                                foodItem['Image'],
                                height: 120,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  '\u{20B9}${foodItem['Price']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodItem['Name'],
                                  style:
                                      AppWidget.semiBoldWhite1TextFeildStyle(),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  foodItem['Detail'],
                                  style: AppWidget.LightTextFeildStyle(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (otherItems.isNotEmpty) ...[
          const SizedBox(height: 20.0),
          Text("Salad and Ice Cream Items",
              style: AppWidget.semiBoldWhiteTextFeildStyle()),
          const SizedBox(height: 10.0),
          Column(
            children: otherItems.map((foodItem) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(
                        detail: foodItem['Detail'],
                        image: foodItem['Image'],
                        name: foodItem['Name'],
                        price: foodItem['Price'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[800],
                  elevation: 5.0,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: Image.network(
                          foodItem['Image'],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodItem['Name'],
                                style: AppWidget.semiBoldWhite1TextFeildStyle(),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                foodItem['Detail'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppWidget.LightTextFeildStyle(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\u{20B9}${foodItem['Price']}',
                                style: AppWidget.semiBoldWhite1TextFeildStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              icecream = true;
              pizza = false;
              salad = false;
              burger = false;
            });
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: icecream ? Colors.black : Colors.grey[800],
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/ice-cream.png",
                fit: BoxFit.cover,
                color: icecream ? Colors.grey[800] : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              icecream = false;
              pizza = true;
              salad = false;
              burger = false;
            });
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: pizza ? Colors.black : Colors.grey[800],
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/pizza.png",
                fit: BoxFit.cover,
                color: pizza ? Colors.grey[800] : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              icecream = false;
              pizza = false;
              salad = true;
              burger = false;
            });
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: salad ? Colors.black : Colors.grey[800],
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/salad.png",
                fit: BoxFit.cover,
                color: salad ? Colors.grey[800] : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              icecream = false;
              pizza = false;
              salad = false;
              burger = true;
            });
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.grey[800],
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "images/burger.png",
                fit: BoxFit.cover,
                color: burger ? Colors.grey[800] : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}