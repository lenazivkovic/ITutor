import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/main.dart';

class EditUsluga extends StatefulWidget {
  const EditUsluga({Key? key, required this.Usluga, required this.idUsluge})
      : super(key: key);

  final Map<String, dynamic> Usluga;
  final String idUsluge;

  @override
  State<EditUsluga> createState() => EditUslugaState();
}

class EditUslugaState extends State<EditUsluga> {
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

  void brisiUslugu() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('BRISANJE USLUGE'),
        content: Text(
            "Da li želite da obrišete uslugu (Ova radnja je nepovratna) ?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('usluge')
                  .doc(widget.idUsluge)
                  .delete()
                  .whenComplete(() => navigatorKey.currentState!
                      .popUntil((route) => route.isFirst));
            },
            child: const Text(
              'Da',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future izmeniUslugu() async {
    if (fotografija != null) {
      final path = 'files/${fotografija!.name}';
      final file = File(fotografija!.path!);

      final storageRef = FirebaseStorage.instance.ref().child(path);

      final snapshot = await storageRef.putFile(file).whenComplete(() async {
        final photoURL = await storageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('usluge')
            .doc(widget.idUsluge)
            .update({
          'tutor': user.uid,
          'stepen': Nivo,
          'opis': opisController.text.trim(),
          'nazivUsluge': nazivController.text.trim(),
          'kategorija': kategorija['nazivKategorije'],
          'fotografija': photoURL,
          'lokacija': grad,
        }).whenComplete(() => Navigator.of(context).pop());
      });
    } else {
      await FirebaseFirestore.instance
          .collection('usluge')
          .doc(widget.idUsluge)
          .update({
        'tutor': user.uid,
        'stepen': Nivo,
        'opis': opisController.text.trim(),
        'nazivUsluge': nazivController.text.trim(),
        'kategorija': kategorija['nazivKategorije'],
        'lokacija': grad,
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
    nazivController.text = widget.Usluga['nazivUsluge'];
    opisController.text = widget.Usluga['opis'];

    FirebaseFirestore.instance.collection('kategorije').get().then((value) {
      List<Map<String, dynamic>> data = [];
      value.docs.forEach((e) {
        final el = e.data();
        data.add(el);
      });
      setState(() {
        Kategorije = data;
        kategorija = data
            .where((element) =>
                element['nazivKategorije'] == (widget.Usluga)['kategorija'])
            .first;
        Nivoi = [(widget.Usluga)['stepen']];
        Nivo = (widget.Usluga)['stepen'];
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
        grad = widget.Usluga['lokacija'];
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
            "Izmenite uslugu",
            style: TextStyle(color: Color.fromRGBO(31, 93, 120, 1)),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: brisiUslugu,
            )
          ],
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
                          SizedBox(
                            child: Image(
                                image: FileImage(File(fotografija!.path!))),
                          ),
                          TextButton(
                              onPressed: selectFile,
                              child: Text("Promenite fotografiju"))
                        ])
                      : Column(children: [
                          SizedBox(
                            height: 200,
                            width: Size.fromHeight(200).width,
                            child: widget.Usluga['fotografija'] != ""
                                ? Image.network(
                                    widget.Usluga['fotografija'],
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.account_circle,
                                    size: 64,
                                    color: Color.fromRGBO(31, 93, 120, 1),
                                  ),
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
                    onPressed: izmeniUslugu,
                    child: Text("Izmenite uslugu"),
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(31, 93, 120, 1)),
                  ),
                ]),
              ],
            ),
          ),
        ));
  }
}
