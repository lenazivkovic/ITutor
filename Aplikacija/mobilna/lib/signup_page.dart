import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobilna/main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, required this.switchPage}) : super(key: key);

  final VoidCallback switchPage;

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  Future signUp() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordContorller.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  bool tutor = false;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordContorller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Form(
          key: formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("assets/images/logo.png"),
                TextFormField(
                  validator: (value) => value == null || value.isEmpty
                      ? "Unesite validan email !"
                      : null,
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email adresa *',
                  ),
                ),
                TextFormField(
                  validator: (value) => value == null || value.length < 8
                      ? "Unesite lozinku od barem 8 karaktera."
                      : null,
                  controller: passwordContorller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Lozinka *',
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: signUp,
                      child: const Text("NAPRAVITE NALOG"),
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(31, 93, 120, 1)),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.switchPage();
                      },
                      child: const Text("Vec imate nalog ? Prijavite se !"),
                      style: TextButton.styleFrom(
                          primary: Color.fromRGBO(31, 93, 120, 1)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
