import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TutorSettings extends StatefulWidget {
  const TutorSettings({Key? key}) : super(key: key);

  @override
  State<TutorSettings> createState() => TutorSettingsState();
}

class TutorSettingsState extends State<TutorSettings> {
  Future selectFile() async {
    PlatformFile? fotografija;
    final file = await FilePicker.platform.pickFiles();
    if (file == null) return;

    setState(() {
      fotografija = file.files.first;
    });

    final path = 'files/${fotografija!.name}';
    final slika = File(fotografija!.path!);

    final storageRef = FirebaseStorage.instance.ref().child(path);

    final snapshot = await storageRef.putFile(slika).whenComplete(() async {
      final photoURL = await storageRef.getDownloadURL();
      FirebaseFirestore.instance
          .collection('tutori')
          .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          final docRef =
              FirebaseFirestore.instance.collection('tutori').doc(element.id);
          docRef.update({'fotografija': photoURL}).whenComplete(() {
            FirebaseAuth.instance.currentUser!.updatePhotoURL(photoURL);
          });
        });
      });
    });
  }

  void promeniBio() {
    final bioController = TextEditingController();

    FirebaseFirestore.instance
        .collection("tutori")
        .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((val) {
      bioController.text = val.docs.first.data()['bio'];
    });

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Promenite opis'),
        content: TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Unesite bio',
          ),
          controller: bioController,
          maxLength: 250,
          maxLines: 10,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otka??i'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('tutori')
                  .where("userID",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .get()
                  .then((value) {
                value.docs.forEach((element) {
                  final docRef = FirebaseFirestore.instance
                      .collection('tutori')
                      .doc(element.id);
                  docRef.update({'bio': bioController.text.trim()});
                });
              }).whenComplete(() => Navigator.pop(context));
            },
            child: const Text('Primeni'),
          ),
        ],
      ),
    );
  }

  void promeniIme() {
    final imeController = TextEditingController();
    final prezimeController = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Promenite ime i prezime'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Unesite ime',
                ),
                controller: imeController,
              ),
              Container(
                height: 15,
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Unesite prezime',
                ),
                controller: prezimeController,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otka??i'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.currentUser!
                  .updateDisplayName(imeController.text.trim() +
                      " " +
                      prezimeController.text.trim())
                  .whenComplete(() {
                FirebaseFirestore.instance
                    .collection('tutori')
                    .where("userID",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .get()
                    .then((value) {
                  value.docs.forEach((element) {
                    final docRef = FirebaseFirestore.instance
                        .collection('tutori')
                        .doc(element.id);
                    docRef.update({
                      'ime': imeController.text.trim(),
                      'prezime': prezimeController.text.trim()
                    });
                  });
                });
              }).whenComplete(() => Navigator.pop(context));
            },
            child: const Text('Primeni'),
          ),
        ],
      ),
    );
  }

  void promeniLozinku() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Promenite lozinku'),
        content: Text(
            "Da li ??elite da Vam se po??alje email sa instrukcijama za resetovanje lozinke ?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.sendPasswordResetEmail(
                  email: FirebaseAuth.instance.currentUser!.email!);
              Navigator.pop(context);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }

  void obrisiteNalog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('BRISANJE NALOGA'),
        content: Text("Da li ??elite da se Va?? nalog potpuno obri??e ?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              Text(
                user.displayName!,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Divider(height: 25),
              Container(
                height: 30,
              ),
              Column(
                children: [
                  user.photoURL != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                              FirebaseAuth.instance.currentUser!.photoURL!),
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
                  TextButton(
                      onPressed: selectFile,
                      child: Text("Promenite profilnu sliku")),
                ],
              ),
              ListTile(
                  leading: Icon(Icons.account_circle_outlined),
                  title: Text("Promenite ime"),
                  subtitle: Text("Ovde mo??ete promeniti ime"),
                  onTap: promeniIme),
              ListTile(
                  leading: Icon(Icons.edit),
                  title: Text("Promenite opis"),
                  subtitle: Text("Ovde mo??ete svoj opis"),
                  onTap: promeniBio),
              ListTile(
                leading: Icon(Icons.key_outlined),
                title: Text("Bezbednost"),
                subtitle: Text("Ovde mo??ete podesiti lozinku naloga"),
                onTap: promeniLozinku,
              ),
              OutlinedButton(
                  onPressed: FirebaseAuth.instance.signOut,
                  child: Text("Odjavi se")),
            ],
          ),
        ),
      ),
    );
  }
}
