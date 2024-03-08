import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/auth/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// ignore: must_be_immutable, camel_case_types
class Profile_page extends StatefulWidget {
  String name;
  String email;
  String phoneNumber;
  Profile_page(
      {super.key,
      required this.email,
      required this.name,
      required this.phoneNumber});

  @override
  State<Profile_page> createState() => _Profile_pageState();
}

class _Profile_pageState extends State<Profile_page> {
  AuthService authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  Widget? imagePreview;
  @override
  void initState() {
    super.initState();
    GetUserPhoto();
  }

  GetUserPhoto() async {
    DocumentReference userDocumentReference = DataBaseService()
        .userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    var encode = documentSnapshot['profilePic'];
    setState(() {
      final List<int> decodedBytes = base64Decode(encode);

      imagePreview = Image.memory(
        Uint8List.fromList(decodedBytes),
        fit: BoxFit.cover,
        width: 190,
        height: 190,
        // Adjust the fit property as needed
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      final file = File(pickedFile!.path);
      List<int> compressedData = await FlutterImageCompress.compressWithList(
          await file.readAsBytes(),
          quality: 50 // Adjust the quality to control the level of compression
          );
      final encoded = base64Encode(compressedData);
      await HelperFunctions.SaveUserPhoto(encoded);
      await DataBaseService()
          .userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"profilePic": encoded});
      GetUserPhoto();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                nextScreen(context, HomePage());
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("Share with your friends"),
            ),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text("Support"),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text("Privacy Policy"),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Log out"),
                        content: Text("Are you sure you want to log out"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await authService.SignOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (route) => false);
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      );  
                    });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Stack(
            children: [
              Positioned(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: imagePreview ??
                    Icon(
                      Icons.account_circle,
                      size: 200,
                      color: Colors.grey[700],
                    ),
              )),
              Positioned(
                  bottom: 20,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          backgroundColor: Theme.of(context).primaryColor,
                          content: Container(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _pickImage(ImageSource.camera);
                                      },
                                      icon: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 50,
                                      )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _pickImage(ImageSource.gallery);
                                      },
                                      icon: Icon(
                                        Icons.browse_gallery_outlined,
                                        size: 50,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ))
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Full Name",
                style: TextStyle(fontSize: 17),
              ),
              Text(
                widget.name,
                style: TextStyle(fontSize: 17),
              )
            ],
          ),
          Divider(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Email",
                style: TextStyle(fontSize: 17),
              ),
              Text(
                widget.email,
                style: TextStyle(fontSize: 17),
              )
            ],
          ),
          Divider(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PhoneNumber",
                style: TextStyle(fontSize: 17),
              ),
              Text(
                widget.phoneNumber,
                style: TextStyle(fontSize: 17),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app)),
              TextButton(
                  onPressed: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Log out"),
                            content: Text("Are you sure you want to log out"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "cancel",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await authService.SignOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                      (route) => false);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )),
            ],
          )
        ]),
      ),
    );
  }
}
