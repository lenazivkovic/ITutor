import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/add_konverzacija.dart';
import 'package:mobilna/main.dart';
import 'package:mobilna/single_chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> sagovornici = [];

  void udjiChat(Map<String, dynamic> sagovornik) {
    navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (builder) => SingleChat(sagovornik: sagovornik)));
  }

  @override
  void initState() {
    final id = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> temp = [];

    FirebaseFirestore.instance
        .collection('konverzacije')
        .where("korisnici", arrayContains: id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        Map<String, dynamic> konvo = element.data();

        String idDrugog = konvo['korisnici'][0] == id
            ? konvo['korisnici'][1]
            : konvo['korisnici'][0];

        FirebaseFirestore.instance
            .collection('ucenici')
            .where("userID", isEqualTo: idDrugog)
            .get()
            .then((value) => {
                  value.docs.forEach((kor) {
                    Map<String, dynamic> koris = kor.data();
                    koris['idKonvo'] = element.id;
                    temp.add(koris);
                  })
                })
            .whenComplete(() {
          FirebaseFirestore.instance
              .collection('tutori')
              .where("userID", isEqualTo: idDrugog)
              .get()
              .then((value) => {
                    value.docs.forEach((kor) {
                      Map<String, dynamic> koris =
                          kor.data() as Map<String, dynamic>;
                      koris['idKonvo'] = element.id;
                      temp.add(koris);
                    })
                  })
              .whenComplete(() {
            temp.forEach((el) {
              FirebaseFirestore.instance
                  .collection('konverzacije/' + el['idKonvo'] + '/poruke')
                  .orderBy("datumVreme", descending: true)
                  .get()
                  .then((value) {
                el['najskorija'] = value.docs.first.data()['poruka'];
              }).whenComplete(() {
                setState(() {
                  sagovornici = temp;
                });
              });
            });
          });
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Adresar",
          style: TextStyle(color: Color.fromRGBO(31, 93, 120, 1)),
        ),
        actions: [Icon(Icons.add)],
      ),
      body: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: sagovornici.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: (sagovornici[index]['fotografija'] != null &&
                      sagovornici[index]['fotografija'] != "")
                  ? CircleAvatar(
                      backgroundImage:
                          NetworkImage(sagovornici[index]['fotografija']),
                    )
                  : Icon(Icons.account_circle),
              title: Text(sagovornici[index]['ime'] +
                  ' ' +
                  sagovornici[index]['prezime']),
              onTap: () => udjiChat(sagovornici[index]),
              subtitle: sagovornici[index]['najskorija'] != null
                  ? Text(sagovornici[index]['najskorija'])
                  : null,
            );
          }),
    );
  }
}
