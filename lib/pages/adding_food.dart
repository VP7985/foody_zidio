import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/services/database.dart';
import 'package:foody_zidio/widget/widget_support.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AddingFood extends StatefulWidget {
  const AddingFood({Key? key}) : super(key: key);

  @override
  State<AddingFood> createState() => _AddingFoodState();
}

class _AddingFoodState extends State<AddingFood> {
  final List<String> fooditems = [
    'Ice-Cream',
    'Pizza',
    'Salad',
    'Burger',
  ];
  String? value;
  File? selectedImage;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  Future<void> getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        selectedImage = File(image.path);
      }
    });
  }

  Future<void> uploadItem() async {
    if (_formKey.currentState!.validate() && selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("foodImages").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();
      Map<String, dynamic> addItem = {
        "Name": namecontroller.text,
        "Price": pricecontroller.text,
        "Detail": detailcontroller.text,
        "Image": downloadUrl,
        "Category": value,
      };
      await _databaseMethods.addFoodItem(addItem, addId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Food item added successfully!",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
      setState(() {
        selectedImage = null;
        namecontroller.clear();
        pricecontroller.clear();
        detailcontroller.clear();
        value = null;
      });
    }
  }

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
        title: Text("Add Food Item", style: AppWidget.semiBoldWhiteTextFeildStyle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: getImage,
                  child: Center(
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: selectedImage == null
                            ? const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Item Name",
                  style: AppWidget.semiBoldWhiteTextFeildStyle(),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: namecontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter item name",
                    hintStyle: AppWidget.semiBoldTextFeildStyle(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Item Price",
                  style: AppWidget.semiBoldWhiteTextFeildStyle(),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: pricecontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item price';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter item price",
                    hintStyle: AppWidget.semiBoldTextFeildStyle(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Item Detail",
                  style: AppWidget.semiBoldWhiteTextFeildStyle(),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: detailcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item detail';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter item detail",
                    hintStyle: AppWidget.semiBoldTextFeildStyle(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Select Category",
                  style: AppWidget.semiBoldWhiteTextFeildStyle(),
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: value,
                  items: fooditems
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                          ))
                      .toList(),
                  onChanged: (item) => setState(() => value = item),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                GestureDetector(
                  onTap: () {
                    uploadItem();
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          "Add Food Item",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}