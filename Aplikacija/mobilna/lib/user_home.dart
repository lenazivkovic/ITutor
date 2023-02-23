import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/chat_page.dart';
import 'user_settings.dart';

import 'search_page.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  State<UserHome> createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  int indexStranice = 0;
  User user = FirebaseAuth.instance.currentUser!;

  static const List<Widget> stranice = <Widget>[
    SearchPage(),
    ChatPage(),
    UserSettings(),
  ];

  void switchIndex(int index) {
    setState(() {
      indexStranice = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: stranice.elementAt(indexStranice),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromRGBO(31, 93, 120, 1),
        unselectedItemColor: Color.fromARGB(255, 49, 138, 190),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Pretraga"),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Poruke"),
          BottomNavigationBarItem(
              icon: user.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL!),
                    )
                  : const Icon(Icons.account_circle),
              label: "Profil"),
        ],
        currentIndex: indexStranice,
        onTap: switchIndex,
      ),
    );
  }
}
