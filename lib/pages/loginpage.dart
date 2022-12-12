import 'dart:developer';

import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/homepage.dart';
import 'package:chatapp/pages/singuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/uihelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UiHelper.showAlertDialog(
          context, "Incomplete Data", "Please Fill All The Fields");
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Logging in...");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (e) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(
          context, " An error occured", e.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("Users").doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      log("Logggin success..");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userModel: userModel,
              firebaseUser: credential!.user!,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Chat App",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: const InputDecoration(
                    hintText: "Enter Your Email",
                    enabledBorder: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Enter Password",
                    enabledBorder: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  checkValue();
                  emailController.clear();
                  passwordController.clear();
                },
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(300, 50)),
                child: const Text("Sign In"),
              )
            ],
          ),
        ),
      )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 16),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ));
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 16),
              ))
        ],
      ),
    );
  }
}
