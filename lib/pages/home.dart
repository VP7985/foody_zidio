import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foody_zidio/pages/details.dart';
import 'package:foody_zidio/pages/order_check.dart';
import 'package:foody_zidio/service/shared_pref.dart';
import 'package:foody_zidio/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = false, salad = false, burger = false;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    onthisload();
  }

  Future<void> fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userName = await SharedPreferenceHelper().getUserName() ?? "User";

        if (userName == "User") {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('User_data')
              .doc(currentUser.uid)
              .get();
          setState(() {
            userName = userDoc['name'] ?? 'User';
          });

          await SharedPreferenceHelper().saveUserName(userName);
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> onthisload() async {
    await fetchUserName();
    setState(() {});
  }

  List<DocumentSnapshot> getFilteredFoodItems(
      List<DocumentSnapshot> foodItems) {
    if (icecream) {
      return foodItems.where((doc) => doc['Category'] == 'Ice-Cream').toList();
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50.0, left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hello $userName,",
                      style: AppWidget.boldTextFeildStyle()),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Ordered(),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 20.0),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text("Delicious Food", style: AppWidget.HeadlineTextFeildStyle()),
              Text("Discover and Get Great Food",
                  style: AppWidget.LightTextFeildStyle()),
              SizedBox(height: 20.0),
              Container(
                  margin: EdgeInsets.only(right: 20.0), child: showItem()),
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
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                            style: AppWidget.semiBoldTextFeildStyle(),
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
    );
  }

  Widget buildListView(List<DocumentSnapshot> foodItems) {
    List<DocumentSnapshot> filteredFoodItems = getFilteredFoodItems(foodItems);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredFoodItems.map((foodItem) {
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
                  margin: EdgeInsets.all(4),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            foodItem['Image'],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          Text(foodItem['Name'],
                              style: AppWidget.semiBoldTextFeildStyle()),
                          SizedBox(height: 5.0),
                          Text(foodItem['Detail'],
                              style: AppWidget.LightTextFeildStyle()),
                          SizedBox(height: 5.0),
                          Text('\u{20B9}${foodItem['Price']}',
                              style: AppWidget.semiBoldTextFeildStyle())
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20.0),
        ...filteredFoodItems.map((foodItem) {
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
              margin: EdgeInsets.only(right: 20.0, bottom: 30.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        foodItem['Image'],
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              foodItem['Name'],
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              foodItem['Detail'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppWidget.LightTextFeildStyle(),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              '\u{20B9}${foodItem['Price']}',
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: icecream ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/ice-cream.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: icecream ? Colors.white : Colors.black,
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: pizza ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/pizza.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: pizza ? Colors.white : Colors.black,
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: salad ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/salad.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: salad ? Colors.white : Colors.black,
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  color: burger ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/burger.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: burger ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
