import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/main.dart';

class AddKonverzacija extends StatefulWidget {
  const AddKonverzacija({Key? key}) : super(key: key);

  State<AddKonverzacija> createState() => AddKonverzacijaState();
}

class AddKonverzacijaState extends State<AddKonverzacija> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> pretraga = [];
  String searchString = "";

  void searchHandler(val) {
    List<Map<String, dynamic>> ptg = [];

    FirebaseFirestore.instance
        .collection('tutori')
        .where("ime", isGreaterThan: searchString)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        Map<String, dynamic> temp = element.data();
        ptg.add(temp);
      });
    }).whenComplete(() {
      FirebaseFirestore.instance
          .collection('usluge')
          .where("ime", isGreaterThan: searchString)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          Map<String, dynamic> temp = element.data();
          ptg.add(temp);
        });
      }).whenComplete(() {
        setState(() {
          pretraga = ptg;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.blue,
          onPressed: navigatorKey.currentState!.pop,
        ),
        title: TextField(
          controller: searchController,
          onChanged: searchHandler,
        ),
      ),
      body: ListView(
          children: pretraga.map((e) {
        return ListTile(title: Text(e['userID']));
      }).toList()),
    );
  }
}
