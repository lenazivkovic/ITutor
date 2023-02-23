import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/add_usluga.dart';
import 'package:mobilna/main.dart';
import 'package:mobilna/pregled_usluge.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mobilna/usluga_edit.dart';

class TutorUsluge extends StatefulWidget {
  const TutorUsluge({Key? key}) : super(key: key);

  @override
  State<TutorUsluge> createState() => TutorUslugeState();
}

class TutorUslugeState extends State<TutorUsluge> {
  final User user = FirebaseAuth.instance.currentUser!;

  void pogledajUslugu(String uslugaID) {
    navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => UslugaPage(
              uslugaID: uslugaID,
              tutor: true,
            )));
  }

  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> uslugeStream = FirebaseFirestore.instance
        .collection('usluge')
        .where('tutor', isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Moje usluge",
          style: TextStyle(color: Color.fromRGBO(31, 93, 120, 1)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: uslugeStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData == false) {
            return Center(
              child: Text("Nemate usluge ? Dodajte neku !"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Učitavanje"));
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> podatak =
                  document.data() as Map<String, dynamic>;
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
                      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    podatak['brojOcena'] != null
                        ? Text(
                            "od " + podatak['brojOcena'].toString() + " ocena")
                        : Text("od 0 ocena")
                  ],
                ),
                onTap: () => pogledajUslugu(document.id),
                trailing: IconButton(
                    onPressed: () =>
                        navigatorKey.currentState!.push(MaterialPageRoute(
                            builder: (builder) => EditUsluga(
                                  Usluga: podatak,
                                  idUsluge: document.id,
                                ))),
                    icon: Icon(Icons.edit)),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigatorKey.currentState!
            .push(MaterialPageRoute(builder: (context) => AddUsluga())),
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(31, 93, 120, 1),
      ),
    );
  }
}
