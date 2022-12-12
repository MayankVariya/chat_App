import 'package:chatapp/pages/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget drawer(context, String? name, String? email, String? url) {
  return Drawer(
    child: ListView(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(name!),
          accountEmail: Text(email!),
          currentAccountPicture: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(url!),
          ),
          arrowColor: Colors.black,
        ),
        ListTile(
            leading: const Icon(Icons.edit),
            title: const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            onTap: () {}),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text(
            "Logout",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();

            Navigator.of(context).popUntil((route) => route.isFirst);

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ));
          },
        ),
      ],
    ),
  );
}
