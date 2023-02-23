import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/tutor_home.dart';
import 'package:mobilna/user_home.dart';
import 'setup_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool first = true;

  bool tutor = false;
  bool ucenik = false;
  bool setup = false;

  void cb() {
    setState(() {
      first = true;
    });
  }

  final user = FirebaseAuth.instance.currentUser!;

  void setWidget() {
    FirebaseFirestore.instance
        .collection("tutori")
        .where("userID", isEqualTo: user.uid)
        .get()
        .then((res) {
      if (res.docs.isNotEmpty) {
        setState(() {
          tutor = true;
        });
      }
    });

    FirebaseFirestore.instance
        .collection("ucenici")
        .where("userID", isEqualTo: user.uid)
        .get()
        .then((res) {
      if (res.docs.isNotEmpty) {
        setState(() {
          ucenik = true;
        });
      }
    });

    setState(() {
      setup = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (first) {
      setWidget();
    }

    if (tutor) {
      return const TutorHome();
    } else if (ucenik) {
      return const UserHome();
    } else if (setup) {
      return SetupProfile(switchNew: cb);
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
