// *** auth page 스크린 ***

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:code230206_hangul_app/main.dart';
import 'screen_home.dart';
import 'snackBarWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:email_validator/email_validator.dart';
import 'screen_auth_Login.dart';
import 'screen_auth_SignUp.dart';

class AuthPageScreen extends StatefulWidget {
  @override
  _AuthPageScreen createState() => _AuthPageScreen();
}

class _AuthPageScreen extends State<AuthPageScreen> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedSignUp: toggle)
      : SignUpWidget(onClickedSignUp: toggle);
  void toggle() => setState(() => isLogin = !isLogin);
}

