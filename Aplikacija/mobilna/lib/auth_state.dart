import 'package:flutter/material.dart';

import 'login_page.dart';
import 'signup_page.dart';

class AuthState extends StatefulWidget {
  const AuthState({Key? key}) : super(key: key);

  @override
  State<AuthState> createState() => AuthStateState();
}

class AuthStateState extends State<AuthState> {
  bool isLogin = true;

  void switchPage() => setState(() => isLogin = !isLogin);

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginPage(switchPage: switchPage)
      : SignUpPage(switchPage: switchPage);
}
