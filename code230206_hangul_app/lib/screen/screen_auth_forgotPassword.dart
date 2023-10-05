// *** 비밀번호 찾기 스크린 ***
// screen_login.dart에서 forgot password를 클릭하면 나오는 스크린
// 이메일을 입력하고 비밀번호를 변경할 수 있음

import 'package:code230206_hangul_app/configuration/my_style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'snackBarWidget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreen createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
        child: Scaffold(
          body: Scaffold(
            backgroundColor: Color(0xffd9ebe5),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.2),
                      TextFormField(
                        controller: emailController,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText: '이메일',
                          labelStyle: TextStyle(color: Colors.black,),
                            prefixIcon: Icon(Icons.email_outlined,color: Colors.black),
                            fillColor: Colors.white,
                            filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.white, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.white, width: 1),),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? '유효한 이메일을 입력해 주세요'
                            : null,
                      ),

                      SizedBox(height: height*0.06),
                      ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                            backgroundColor: Color(0xFF74B29E),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                        ),
                        child: Text('비밀번호 재설정', style: TextStyle(fontSize: width * 0.045, color: Colors.white),),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
  
  Future resetPassword() async {
    showDialog(
        context: this.context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );
    try {
     await FirebaseAuth.instance
         .sendPasswordResetEmail(email: emailController.text.trim());
     SnackBarWidget.showSnackBar('비밀번호 재설정 이메일이 발송되었습니다');
     Navigator.of(context).popUntil((route) => route.isFirst);
   } on FirebaseAuthException catch (e) {
      print(e);
      SnackBarWidget.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}