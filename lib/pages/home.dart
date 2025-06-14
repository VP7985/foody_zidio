import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foody_zidio/pages/details.dart';
import 'package:foody_zidio/pages/my_order.dart';
import 'package:foody_zidio/services/local_cache.dart';
import 'package:foody_zidio/widget/widget_support.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = false, salad = false, burger = false;
  String userName = "User";
  final LocalCacheService _cacheService = LocalCacheService();

  @override
  void initState() {
    super.initState();
    onthisload();
  }

  Future<void> fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, String>? cachedData = await _cacheService.getUserData(currentUser.uid);
        if (cachedData != null && _cacheService.isCacheValid(cachedData)) {
          setState(() {
            userName = cachedData['name'] ?? 'User';
          });
        } else {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('User_data')
              .doc(currentUser.uid)
              .get();
          String name = userDoc['name'] ?? 'User';
          String timestamp = DateTime.now().toIso8601String();
          await FirebaseFirestore.instance
              .collection('User_data')
              .doc(currentUser.uid)
              .update({'LastLoginTimestamp': timestamp});
          await _cacheService.saveUserData(
            id: currentUser.uid,
            name: name,
            email: currentUser.email,
            lastLoginTimestamp: timestamp,
          );
          setState(() {
            userName = name;
          });
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await onthisload();
  }

  Future<void> onthisload() async {
    await fetchUserName();
    setState(() {});
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
          icon: Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Foody Zidio",
          style: AppWidget.semiBoldWhiteTextFeildStyle(),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Ordered()),
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 20.0),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: Colors.white,
        backgroundColor: Colors.black,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello $userName🥰", style: AppWidget.semiBoldWhiteTextFeildStyle()),
                SizedBox(height: 10.0),
                Text("Delicious Food",
                    style: AppWidget.HeadlineTextFeildStyle()),
                Text("Discover and Get Great Food",
                    style: AppWidget.LightTextFeildStyle()),
                SizedBox(height: 20.0),
                showItem(),
                SizedBox(height: 30.0),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('foodItems')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
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
                              style: AppWidget.semiBoldWhiteTextFeildStyle(),
                            ),
                          ],
                        ),
                      );
                    } else {
                      List<DocumentSnapshot> foodItems = snapshot.data!.docs;
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
          SizedBox(height: 20.0),
          Text(
            "Burger and Pizza Items",
            style: AppWidget.semiBoldWhiteTextFeildStyle(),
          ),
          SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: burgerPizzaItems.map((foodItem) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
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
                    margin: EdgeInsets.all(8),
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[800],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
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
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  '\u{20B9}${foodItem['Price']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodItem['Name'],
                                  style: AppWidget.semiBoldWhite1TextFeildStyle(),
                                ),
                                SizedBox(height: 4),
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
          SizedBox(height: 20.0),
          Text(
            "Salad and Ice Cream Items",
            style: AppWidget.semiBoldWhiteTextFeildStyle(),
          ),
          SizedBox(height: 10.0),
          Column(
            children: otherItems.map((foodItem) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
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
                  margin: EdgeInsets.only(bottom: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
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
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodItem['Name'],
                                style: AppWidget.semiBoldWhite1TextFeildStyle(),
                              ),
                              SizedBox(height: 4),
                              Text(
                                foodItem['Detail'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppWidget.LightTextFeildStyle(),
                              ),
                              SizedBox(height: 8),
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
              padding: EdgeInsets.all(8),
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
              padding: EdgeInsets.all(8),
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
              padding: EdgeInsets.all(8),
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
              padding: EdgeInsets.all(8),
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