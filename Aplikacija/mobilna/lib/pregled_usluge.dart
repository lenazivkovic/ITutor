import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mobilna/main.dart';
import 'tutor_profile.dart';

class UslugaPage extends StatefulWidget {
  const UslugaPage({Key? key, required this.uslugaID, required this.tutor})
      : super(key: key);

  final String uslugaID;
  final bool tutor;

  @override
  State<UslugaPage> createState() => UslugaPageState();
}

class UslugaPageState extends State<UslugaPage> {
  final User user = FirebaseAuth.instance.currentUser!;

  double rating = 0.0;
  final ocenaController = TextEditingController();
  Map<String, dynamic>? dokument;
  Map<String, dynamic>? tutor;
  Map<String, dynamic>? ocena;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() {
    Map<String, dynamic>? tDoc;
    Map<String, dynamic>? tTut;

    if (widget.tutor == false) {
      FirebaseFirestore.instance
          .collection("ocene")
          .where("korisnikID", isEqualTo: user.uid)
          .where("uslugaID", isEqualTo: widget.uslugaID)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          setState(() {
            ocena = element.data();
          });
        });
      });
    }

    FirebaseFirestore.instance
        .collection('usluge')
        .doc(widget.uslugaID)
        .get()
        .then((value) {
      tDoc = value.data();
    }).whenComplete(() {
      FirebaseFirestore.instance
          .collection('tutori')
          .where("userID", isEqualTo: tDoc!['tutor'])
          .get()
          .then((value) {
        value.docs.forEach((element) {
          tTut = element.data();
          tTut!['docID'] = element.id;
        });
      }).whenComplete(() {
        setState(() {
          dokument = tDoc;
          tutor = tTut;
        });
      });
    });
  }

  void oceni() {
    FirebaseFirestore.instance.collection("ocene").add({
      "ocena": rating,
      "komentar": ocenaController.text.trim(),
      "nova": true,
      "oznacena": false,
      "datum": Timestamp.now(),
      "korisnikID": user.uid,
      "uslugaID": widget.uslugaID,
    }).whenComplete(() {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final oceneStream = FirebaseFirestore.instance
        .collection("ocene")
        .where("uslugaID", isEqualTo: widget.uslugaID)
        .snapshots();

    if (dokument != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(
            onPressed: navigatorKey.currentState!.pop,
            color: Color.fromRGBO(31, 93, 120, 1),
          ),
          title: Text(
            dokument!['nazivUsluge'],
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                width: Size.fromHeight(200).width,
                child: dokument!['fotografija'] != null &&
                        dokument!['fotografija'] != ""
                    ? Image.network(
                        dokument!['fotografija'],
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              Container(
                height: 40,
              ),
              Text(
                "${dokument!['kategorija']} , ${dokument!['stepen']}",
                style: TextStyle(fontSize: 18),
              ),
              Container(
                height: 15,
              ),
              Text(
                "Opis :",
                style: TextStyle(fontSize: 20),
              ),
              Container(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.0, color: Color.fromRGBO(31, 93, 120, 1)),
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  dokument!['opis'],
                  maxLines: 20,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Container(
                height: 40,
              ),
              Container(
                child: widget.tutor
                    ? null
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tutor :",
                            style: TextStyle(fontSize: 20),
                          ),
                          Container(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.0,
                                    color: Color.fromRGBO(31, 93, 120, 1)),
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: tutor!['fotografija'] != "" &&
                                      tutor!['fotografija'] != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(tutor!['fotografija']))
                                  : Icon(Icons.account_circle),
                              title:
                                  Text(tutor!['ime'] + ' ' + tutor!['prezime']),
                              onTap: () => navigatorKey.currentState!.push(
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          TutorProfile(tutorProfil: tutor!))),
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                height: 40,
              ),
              Container(
                child: widget.tutor == true
                    ? null
                    : ocena == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Divider(
                                height: 10,
                                color: Color.fromRGBO(31, 93, 120, 1),
                              ),
                              Container(
                                height: 15,
                              ),
                              Text(
                                "Ocenite uslugu :",
                                style: TextStyle(fontSize: 20),
                              ),
                              Container(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RatingBar.builder(
                                    initialRating: rating,
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 25,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (value) {
                                      setState(() {
                                        rating = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Container(
                                height: 15,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Komentar *',
                                ),
                                controller: ocenaController,
                              ),
                              ElevatedButton(
                                onPressed: () => oceni(),
                                child: Text("Ocenite !"),
                                style: ElevatedButton.styleFrom(
                                    primary: Color.fromRGBO(31, 93, 120, 1)),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Divider(
                                height: 10,
                                color: Color.fromRGBO(31, 93, 120, 1),
                              ),
                              Container(
                                height: 15,
                              ),
                              Text(
                                "Vaša ocena :",
                                style: TextStyle(fontSize: 20),
                              ),
                              Container(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RatingBarIndicator(
                                    rating: ocena!['ocena'].toDouble(),
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemSize: 20,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 15,
                              ),
                              Text(
                                ocena!['komentar'],
                                maxLines: 10,
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: navigatorKey.currentState!.pop,
              color: Color.fromRGBO(31, 93, 120, 1),
            ),
          ),
          body: Center(
            child: Text("Učitava se dokument ..."),
          ));
    }
  }
}
