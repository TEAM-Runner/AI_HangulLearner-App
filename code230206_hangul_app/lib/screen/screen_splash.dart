import 'dart:async';

import 'package:code230206_hangul_app/screen/screen_auth_Login.dart';
import 'package:flutter/material.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({Key? key}) : super(key: key);

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {

  ///set 3s time-out
  late Timer _timer;

  @override
  void initState() {
    _timer=Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
    super.initState();
  }

  ///set a animation and "ㅇㅇㅎㄱ" icon
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: const Image(
            image: AssetImage("assets/images/splash.png"),
            fit: BoxFit.cover,
          )),
    );
  }
}
