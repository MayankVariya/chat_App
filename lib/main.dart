import 'package:chatapp/models/firebasehelper.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'pages/loginpage.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          ChatAppLoggin(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const ChatApp());
    }
  } else {
    runApp(const ChatApp());
  }
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginPage(),
    );
  }
}

class ChatAppLoggin extends StatelessWidget {
  const ChatAppLoggin(
      {super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
