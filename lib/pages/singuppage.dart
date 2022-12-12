import 'package:chatapp/models/uihelper.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/complatprofile.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      UiHelper.showAlertDialog(
          context, "Incomplete Data", "Please Fill All The Fields");
    } else if (password != cpassword) {
      UiHelper.showAlertDialog(context, "password Mismatch",
          "The passwords you entered do not match!");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Sign Up...");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (ex) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, fullName: "", email: email, profilePic: "");
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        ("New User Created !");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ComplateProfilePage(
                  userModel: newUser, firebaseUser: credential!.user!),
            ));
        emailController.clear();
        passwordController.clear();
        cPasswordController.clear();
      });
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
              TextFormField(
                controller: cPasswordController,
                decoration: const InputDecoration(
                    hintText: "Enter Confirm Password",
                    enabledBorder: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  checkValue();
                },
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(300, 50)),
                child: const Text("Sign Up"),
              )
            ],
          ),
        ),
      )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(fontSize: 16),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 16),
              ))
        ],
      ),
    );
  }
}
