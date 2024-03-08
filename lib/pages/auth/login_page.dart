import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/auth/register_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/shared/constants.dart';
import 'package:chatapp/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _success = true;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Groupie",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Login now to See What they are talking!",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              Image.asset("assets/login.png"),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Constants().primaryColor,
                    )),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                validator: (val) {
                  return RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val!)
                      ? null
                      : "Please enter a valid email";
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                obscureText: true,
                decoration: textInputDecoration.copyWith(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Constants().primaryColor,
                    )),
                validator: (val) {
                  if (val!.length < 6) {
                    return "PassWord must be At Least 6 characters";
                  } else {
                    return null;
                  }
                },
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Constants().primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: _success == true
                      ? const Text(
                          "Sign in",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                  onPressed: () {
                    login();
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text.rich(TextSpan(
                  text: "Don't have an Account?",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                        text: "Register here",
                        style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            nextScreen(context, const RegisterPage());
                          })
                  ])),
            ],
          )),
    )));
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _success = false;
      });

      bool success = await authService.LoginWithEmailAndPassword(
        email,
        password,
      );

      if (success) {
        // HomePage
        QuerySnapshot snapshot =
            await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .GettingUserData(email);
        await HelperFunctions.SaveUserLoggedInStatus(true);
        await HelperFunctions.SaveUserName(snapshot.docs[0]['fullName']);
        await HelperFunctions.SaveUserEmail(email);
        await HelperFunctions.SaveUserPhone(snapshot.docs[0]['PhoneNumber']);
        // ignore: use_build_context_synchronously
        nextScreenReplace(context, const HomePage());
        // Registration successful, handle the next steps
      } else {
        // ignore: use_build_context_synchronously
        showsnackbar(context, Colors.red, success);
      }

      setState(() {
        _success = false;
      });
    }
  }
}
