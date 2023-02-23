import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mobilna/main.dart';
import 'package:mobilna/single_chat.dart';

class TutorProfile extends StatefulWidget {
  const TutorProfile({Key? key, required this.tutorProfil}) : super(key: key);

  final Map<String, dynamic> tutorProfil;

  @override
  State<TutorProfile> createState() => TutorProfileState();
}

class TutorProfileState extends State<TutorProfile> {
  bool dodatUAdresar = false;

  void posaljitePoruku() {
    FirebaseFirestore.instance.collection("konverzacije").add({
      'korisnici': [
        FirebaseAuth.instance.currentUser!.uid,
        widget.tutorProfil['userID']
      ]
    }).then((value) {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    });
  }

  List<Map<String, dynamic>>? usluge;

  @override
  void initState() {
    List<Map<String, dynamic>> temp = [];

    FirebaseFirestore.instance
        .collection("konverzacije")
        .where("korisnici",
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element['korisnici'].contains(widget.tutorProfil['userID'])) {
          setState(() {
            dodatUAdresar = true;
          });
        }
      });
    }).whenComplete(() {});

    FirebaseFirestore.instance
        .collection("usluge")
        .where("tutor", isEqualTo: widget.tutorProfil['userID'])
        .limit(5)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        temp.add(element.data());
      });
    }).whenComplete(() {
      setState(() {
        usluge = temp;
      });
    });

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.blue,
            onPressed: navigatorKey.currentState!.pop,
          ),
          actions: [
            IconButton(
                onPressed: dodatUAdresar ? null : posaljitePoruku,
                icon: Icon(
                  Icons.send_outlined,
                  color: dodatUAdresar ? Colors.grey : Colors.blue,
                ))
          ],
          title: Text(
              widget.tutorProfil['ime'] + ' ' + widget.tutorProfil['prezime'])),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.tutorProfil['fotografija'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                widget.tutorProfil['fotografija']!),
                            radius: 64,
                          )
                        : CircleAvatar(
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 64,
                            ),
                            radius: 40,
                            backgroundColor: Colors.grey,
                          ),
                    Container(
                      height: 15,
                    ),
                    Text(
                      widget.tutorProfil['ime'] +
                          ' ' +
                          widget.tutorProfil['prezime'],
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                    ),
                    Text(
                      "Biografija :",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.blue,
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        widget.tutorProfil['bio'],
                        maxLines: 20,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: dodatUAdresar ? null : posaljitePoruku,
                        child: Text(dodatUAdresar
                            ? "Tutor je u adresaru !"
                            : "Dodajte u adresar !")),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 15,
                    ),
                    Text(
                      "Popularne usluge :",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.blue,
                    ),
                    usluge != null
                        ? Column(
                            children: usluge!.map((podatak) {
                              return ListTile(
                                isThreeLine: true,
                                leading: podatak['fotografija'] != null &&
                                        podatak['fotografija'] != ""
                                    ? SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: Image.network(
                                          podatak['fotografija'],
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )
                                    : Icon(Icons.no_photography_outlined),
                                title: Text(podatak['nazivUsluge']),
                                subtitle: Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: podatak['srednjaOcena'] != null
                                          ? podatak['srednjaOcena'].toDouble()
                                          : 0,
                                      direction: Axis.horizontal,
                                      itemCount: 5,
                                      itemSize: 15,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 2.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    podatak['brojOcena'] != null
                                        ? Text("od " +
                                            podatak['brojOcena'].toString() +
                                            " ocena")
                                        : Text("od 0 ocena")
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        : Text("Tutor nema usluge :(")
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
