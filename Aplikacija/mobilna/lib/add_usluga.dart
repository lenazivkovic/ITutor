import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/main.dart';

class AddUsluga extends StatefulWidget {
  const AddUsluga({Key? key}) : super(key: key);

  @override
  State<AddUsluga> createState() => AddUslugaState();
}

class AddUslugaState extends State<AddUsluga> {
  final User user = FirebaseAuth.instance.currentUser!;

  PlatformFile? fotografija;

  List<Map<String, dynamic>> Kategorije = [];
  Map<String, dynamic> kategorija = {};

  List<String> Nivoi = [];
  String Nivo = "";

  List<String> Gradovi = [];
  String grad = "";

  final opisController = TextEditingController();
  final nazivController = TextEditingController();

  Future selectFile() async {
    final file = await FilePicker.platform.pickFiles();
    if (file == null) return;

    setState(() {
      fotografija = file.files.first;
    });
  }

  Future dodajUslugu() async {
    if (fotografija != null) {
      final path = 'files/${fotografija!.name}';
      final file = File(fotografija!.path!);

      final storageRef = FirebaseStorage.instance.ref().child(path);

      final snapshot = await storageRef.putFile(file).whenComplete(() async {
        final photoURL = await storageRef.getDownloadURL();
        FirebaseFirestore.instance.collection('usluge').add({
          'tutor': user.uid,
          'stepen': Nivo,
          'opis': opisController.text.trim(),
          'nazivUsluge': nazivController.text.trim(),
          'kategorija': kategorija['nazivKategorije'],
          'fotografija': photoURL,
          'lokacija': grad,
          'brojOcena': 0,
          'srednjaOcena': 0,
          'dodatoNa': Timestamp.fromDate(DateTime.now())
        }).whenComplete(() => Navigator.of(context).pop());
      });
    } else {
      FirebaseFirestore.instance.collection('usluge').add({
        'tutor': user.uid,
        'stepen': Nivo,
        'opis': opisController.text.trim(),
        'nazivUsluge': nazivController.text.trim(),
        'kategorija': kategorija['nazivKategorije'],
        'fotografija': "",
        'lokacija': grad,
        'brojOcena': 0,
        'srednjaOcena': 0,
        'dodatoNa': Timestamp.fromDate(DateTime.now())
      }).whenComplete(() => Navigator.of(context).pop());
    }
  }

  void setKategoriju(value) {
    List<String> temp = [];
    value['stepen'].forEach((val) {
      temp.add(val);
    });
    debugPrint(temp.first);
    setState(() {
      Nivoi = temp;
      Nivo = temp.first;
      kategorija = value;
    });
  }

  @override
  void initState() {
    FirebaseFirestore.instance.collection('kategorije').get().then((value) {
      List<Map<String, dynamic>> data = [];
      value.docs.forEach((e) {
        final el = e.data();
        data.add(el);
      });
      setState(() {
        Kategorije = data;
        kategorija = data.first;
      });
    });

    FirebaseFirestore.instance.collection('lokacija').get().then((value) {
      List<String> data = [];
      value.docs.forEach((e) {
        final el = e.data();
        data.add(el['grad']);
      });
      setState(() {
        Gradovi = data;
        grad = data.first;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Color.fromRGBO(31, 93, 120, 1),
            onPressed: navigatorKey.currentState!.pop,
          ),
          title: Text(
            "Dodaj uslugu !",
            style: TextStyle(color: Color.fromRGBO(31, 93, 120, 1)),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: fotografija != null
                      ? Column(children: [
                          Image(image: FileImage(File(fotografija!.path!))),
                          TextButton(
                            onPressed: selectFile,
                            child: Text("Promenite fotografiju"),
                            style: TextButton.styleFrom(
                                primary: Color.fromRGBO(31, 93, 120, 1)),
                          )
                        ])
                      : Column(children: [
                          Icon(
                            Icons.account_circle,
                            size: 64,
                            color: Colors.blue,
                          ),
                          TextButton(
                            onPressed: selectFile,
                            child: Text("Promenite fotografiju"),
                            style: TextButton.styleFrom(
                                primary: Color.fromRGBO(31, 93, 120, 1)),
                          )
                        ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Naziv usluge *',
                    ),
                    controller: nazivController,
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "Kategorija",
                    style: TextStyle(fontSize: 20),
                  ),
                  DropdownButton<Map<String, dynamic>>(
                    value: kategorija,
                    onChanged: (value) => setKategoriju(value),
                    items:
                        Kategorije.map<DropdownMenuItem<Map<String, dynamic>>>(
                            (Map<String, dynamic> value) {
                      return DropdownMenuItem(
                          value: value, child: Text(value['nazivKategorije']));
                    }).toList(),
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "Nivo stručne spreme",
                    style: TextStyle(fontSize: 20),
                  ),
                  DropdownButton<String>(
                    value: Nivo,
                    onChanged: (value) {
                      setState(() {
                        Nivo = value!;
                      });
                    },
                    items: Nivoi.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "Lokacija",
                    style: TextStyle(fontSize: 20),
                  ),
                  DropdownButton<String>(
                    value: grad,
                    onChanged: (value) {
                      setState(() {
                        grad = value!;
                      });
                    },
                    items:
                        Gradovi.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                  ),
                  Container(
                    height: 20,
                  ),
                  TextField(
                    minLines: 5,
                    maxLines: 20,
                    maxLength: 250,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Opišite uslugu u par rečenica.',
                    ),
                    controller: opisController,
                  ),
                  ElevatedButton(
                    onPressed: dodajUslugu,
                    child: Text("DODAJTE USLUGU !"),
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(31, 93, 120, 1)),
                  )
                ]),
              ],
            ),
          ),
        ));
  }
}
