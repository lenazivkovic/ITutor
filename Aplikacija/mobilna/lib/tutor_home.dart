import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/chat_page.dart';
import 'package:mobilna/tutor_ocene.dart';
import 'package:mobilna/tutor_settings.dart';
import 'tutor_usluge.dart';
import 'tutor_settings.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({Key? key}) : super(key: key);

  @override
  State<TutorHome> createState() => TutorHomeState();
}

class TutorHomeState extends State<TutorHome> {
  int indexStranice = 0;
  User user = FirebaseAuth.instance.currentUser!;

  static const List<Widget> stranice = <Widget>[
    TutorUsluge(),
    ChatPage(),
    TutorOcene(),
    TutorSettings(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: "Moje usluge",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: "Adresar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Ocene",
          ),
          BottomNavigationBarItem(
            icon: user.photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL!),
                  )
                : const Icon(Icons.account_circle),
            label: "Profil",
          ),
        ],
        currentIndex: indexStranice,
        onTap: switchIndex,
      ),
    );
  }
}
