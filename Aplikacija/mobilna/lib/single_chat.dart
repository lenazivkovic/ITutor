import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/chat_page.dart';
import 'package:mobilna/main.dart';
import 'package:mobilna/tutor_settings.dart';
import 'tutor_usluge.dart';
import 'tutor_settings.dart';
import 'message_chip.dart';

class SingleChat extends StatefulWidget {
  const SingleChat({Key? key, required this.sagovornik}) : super(key: key);

  final Map<String, dynamic> sagovornik;

  @override
  State<SingleChat> createState() => SingleChatState();
}

class SingleChatState extends State<SingleChat> {
  Map<String, dynamic> sagovornik = {};

  final porukaController = TextEditingController();

  @override
  void initState() {
    sagovornik = widget.sagovornik;

    super.initState();
  }

  void posaljiPoruku() {
    FirebaseFirestore.instance
        .collection('konverzacije/' + sagovornik['idKonvo'] + '/poruke')
        .add({
      'od': FirebaseAuth.instance.currentUser!.uid,
      'datumVreme': Timestamp.fromDate(DateTime.now()),
      'poruka': porukaController.text.trim(),
      'svidjano': false
    }).whenComplete(() => porukaController.clear());
  }

  @override
  Widget build(BuildContext context) {
    final id = FirebaseAuth.instance.currentUser!.uid;
    final Stream<QuerySnapshot> porukeStream = FirebaseFirestore.instance
        .collection('konverzacije/' + sagovornik['idKonvo'] + '/poruke')
        .orderBy("datumVreme", descending: true)
        .limit(25)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
          title: ListTile(
              leading: sagovornik['fotografija'] != null &&
                      sagovornik['fotografija'] != ""
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(sagovornik['fotografija']))
                  : Icon(Icons.account_circle),
              title: Text(sagovornik['ime'] + " " + sagovornik['prezime'])),
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Color.fromRGBO(31, 93, 120, 1),
            onPressed: navigatorKey.currentState!.pop,
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: porukeStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData == false) {
            return Center();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Učitavanje"));
          }

          return ListView(
            reverse: true,
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> podatak =
                  document.data() as Map<String, dynamic>;
              podatak['idPoruke'] = document.id;
              return MessageChip(poruka: podatak);
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
          child: ListTile(
        title: TextField(
          controller: porukaController,
        ),
        trailing: IconButton(
          icon: Icon(Icons.send),
          onPressed: posaljiPoruku,
        ),
      )),
    );
  }
}
