import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/main.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({Key? key, required this.switchNew}) : super(key: key);

  final VoidCallback switchNew;

  @override
  State<SetupProfile> createState() => SetupProfileState();
}

class SetupProfileState extends State<SetupProfile> {
  bool isTutor = false;
  final formKey = GlobalKey<FormState>();
  final imeController = TextEditingController();
  final prezimeController = TextEditingController();

  Future setupProfile() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    final User user = FirebaseAuth.instance.currentUser!;
    final isValid = formKey.currentState!.validate();

    FirebaseAuth.instance.currentUser!.updateDisplayName(
        imeController.text.trim() + ' ' + prezimeController.text.trim());

    if (isTutor) {
      await FirebaseFirestore.instance.collection("tutori").add({
        'userID': user.uid,
        'ime': imeController.text.trim(),
        'prezime': prezimeController.text.trim(),
        'fotografija': FirebaseAuth.instance.currentUser!.photoURL != null
            ? FirebaseAuth.instance.currentUser!.photoURL
            : "",
        'bio': "",
        'dodatoNa': Timestamp.fromDate(DateTime.now())
      });
    } else {
      await FirebaseFirestore.instance.collection("ucenici").add({
        'userID': user.uid,
        'ime': imeController.text.trim(),
        'prezime': prezimeController.text.trim(),
        'fotografija': FirebaseAuth.instance.currentUser!.photoURL != null
            ? FirebaseAuth.instance.currentUser!.photoURL
            : "",
        'dodatoNa': Timestamp.fromDate(DateTime.now())
      });
    }
    widget.switchNew();
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 16.0),
                  child: Image.asset("assets/images/logo.png"),
                ),
                const Text(
                  "PODESITE SVOJ PROFIL",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(31, 93, 120, 1)),
                ),
                const Text(
                  "Još samo par koraka.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(31, 93, 120, 1),
                  ),
                ),
                TextFormField(
                  validator: (value) =>
                      value == null || value.isEmpty ? "Unesite ime !" : null,
                  controller: imeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ime *',
                  ),
                ),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? "Unesite prezime !"
                      : null,
                  controller: prezimeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Prezime *',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    !isTutor
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.backpack_outlined),
                            label: const Text("Učenik"),
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(31, 93, 120, 1)),
                            onPressed: () {},
                          )
                        : OutlinedButton.icon(
                            icon: const Icon(Icons.backpack_outlined),
                            label: const Text("Učenik"),
                            onPressed: () {
                              setState(() {
                                isTutor = false;
                              });
                            },
                          ),
                    isTutor
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.book_outlined),
                            label: const Text("Tutor"),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(31, 93, 120, 1)),
                          )
                        : OutlinedButton.icon(
                            icon: const Icon(Icons.book_outlined),
                            label: const Text("Tutor"),
                            onPressed: () {
                              setState(() {
                                isTutor = true;
                              });
                            },
                          ),
                  ],
                ),
                ElevatedButton(
                    onPressed: setupProfile,
                    child: const Text("Podesite profil !"),
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(31, 93, 120, 1))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
