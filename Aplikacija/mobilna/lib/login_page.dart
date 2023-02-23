import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobilna/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.switchPage}) : super(key: key);

  final VoidCallback switchPage;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordContorller = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordContorller.dispose();
    super.dispose();
  }

  void zaboravljenaLozinka() {
    final zabLoz = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Unesite email naloga !'),
        content: TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email adresa *',
          ),
          controller: zabLoz,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance
                  .sendPasswordResetEmail(email: zabLoz.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordContorller.text.trim());
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("assets/images/logo.png"),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email adresa *',
                  ),
                ),
                TextField(
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
                      onPressed: signIn,
                      child: const Text("PRIJAVITE SE"),
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(31, 93, 120, 1)),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.switchPage();
                      },
                      child: const Text("Nemate nalog ? Napravite novi !"),
                      style: TextButton.styleFrom(
                          primary: Color.fromRGBO(31, 93, 120, 1)),
                    ),
                    ElevatedButton(
                      onPressed: signInWithGoogle,
                      child: const Text("PRIJAVITE SE PREKO GOOGLE-A"),
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(31, 93, 120, 1)),
                    ),
                    TextButton(
                      onPressed: zaboravljenaLozinka,
                      child: const Text("Zaboravili ste lozinku ?"),
                      style: TextButton.styleFrom(
                          primary: Color.fromRGBO(31, 93, 120, 1)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
