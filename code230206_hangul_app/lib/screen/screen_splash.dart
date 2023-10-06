import 'dart:async';

import 'package:code230206_hangul_app/screen/screen_auth_Login.dart';
import 'package:flutter/material.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({Key? key}) : super(key: key);

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  ///addPostFrameCallback method: when flutter widget were builded, do something
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((Duration duration) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => route == null);
      });
    });
  }

  ///set a animation and "ㅇㅇㅎㄱ" icon
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff74b29e),
        child: Center(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white, // 로고를 흰색으로 변경할 색상
              BlendMode.srcATop, // 블렌딩 모드
            ),
            child: Image.asset('assets/images/brand_logo.png'), // 로고 이미지 파일 경로로 변경해야 합니다.
          ),
        ),
      ),
    );
  }
}
