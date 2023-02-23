import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mobilna/chat_page.dart';
import 'user_settings.dart';

import 'search_page.dart';

class TutorOcene extends StatefulWidget {
  const TutorOcene({Key? key}) : super(key: key);

  @override
  State<TutorOcene> createState() => TutorOceneState();
}

class TutorOceneState extends State<TutorOcene> {
  List<Map<String, dynamic>> ocene = [];
  List<Map<String, dynamic>> usluge = [];

  void prijaviUslugu(id) {
    var docRef = FirebaseFirestore.instance
        .collection("ocene")
        .doc(id)
        .update({"oznacena": true});

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prijavljivanje ocena'),
          content: const Text("Uspešno prijavljena ocena !"),
          actions: <Widget>[
            TextButton(
              child: const Text('Okej !'),
              onPressed: () {
                LoadData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void klikNaOcenu(ocena) {
    FirebaseFirestore.instance
        .collection("ocene")
        .doc(ocena['docID'])
        .update({"nova": false});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: usluge
                      .where(
                          (element) => element['idUsluge'] == ocena['uslugaID'])
                      .first['nazivUsluge']
                      .length >
                  30
              ? Text(usluge
                  .where((element) => element['idUsluge'] == ocena['uslugaID'])
                  .first['nazivUsluge']
                  .substring(0, 30))
              : Text(usluge
                  .where((element) => element['idUsluge'] == ocena['uslugaID'])
                  .first['nazivUsluge']),
          content: SingleChildScrollView(
            child: Column(children: [
              RatingBarIndicator(
                rating: ocena['ocena'].toDouble(),
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 20,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
              Container(
                height: 10,
              ),
              Text(
                ocena['komentar'],
              ),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okej !'),
              onPressed: () {
                LoadData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void LoadData() {
    final id = FirebaseAuth.instance.currentUser!.uid;

    List<Map<String, dynamic>> tUsluge = [];
    List<String> idjevi = [];
    List<Map<String, dynamic>> temp = [];

    FirebaseFirestore.instance
        .collection('usluge')
        .where("tutor", isEqualTo: id)
        .get()
        .then((value) {
      value.docs.forEach((doc) {
        var temp = doc.data();
        temp['idUsluge'] = doc.id;
        tUsluge.add(temp);
        idjevi.add(doc.id);
      });
    }).whenComplete(() {
      FirebaseFirestore.instance
          .collection("ocene")
          .where("uslugaID", whereIn: idjevi)
          .where("oznacena", isEqualTo: false)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          var t = element.data();
          t['docID'] = element.id;
          temp.add(t);
        });
      }).whenComplete(() {
        setState(() {
          ocene = temp;
          usluge = tUsluge;
        });
      });
    });
  }

  @override
  void initState() {
    LoadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Ocene usluga",
            style: TextStyle(
              color: Color.fromRGBO(31, 93, 120, 1),
            ),
          )),
      body: ListView.builder(
          itemCount: ocene.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => klikNaOcenu(ocene[index]),
              tileColor:
                  ocene[index]['nova'] == true ? Colors.blue[50] : Colors.white,
              title: Text(ocene[index]['komentar']),
              subtitle: Row(children: [
                RatingBarIndicator(
                  rating: ocene[index]['ocena'].toDouble(),
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 15,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
                usluge
                            .where((element) =>
                                element['idUsluge'] == ocene[index]['uslugaID'])
                            .first['nazivUsluge']
                            .length >
                        30
                    ? Text(usluge
                        .where((element) =>
                            element['idUsluge'] == ocene[index]['uslugaID'])
                        .first['nazivUsluge']
                        .substring(0, 30))
                    : Text(
                        usluge
                            .where((element) =>
                                element['idUsluge'] == ocene[index]['uslugaID'])
                            .first['nazivUsluge'],
                      ),
              ]),
              trailing: OutlinedButton(
                child: Icon(Icons.report, color: Colors.red),
                onPressed: () => prijaviUslugu(ocene[index]['docID']),
              ),
            );
          }),
    );
  }
}
