// *** sign up 스크린 ***

import 'package:code230206_hangul_app/configuration/my_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:code230206_hangul_app/main.dart';
import 'screen_home.dart';
import 'snackBarWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:email_validator/email_validator.dart';
import 'screen_auth_Login.dart';
import 'screen_auth_SignUp.dart';
import 'screen_auth_authPage.dart';

class SignUpWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const SignUpWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _SignUpWidget createState() => _SignUpWidget();
}

class _SignUpWidget extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
          backgroundColor: Color(0xffd9ebe5),
          body: SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.08),
              child: Form (
                key: formKey,
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.2),
                    TextFormField(
                      controller: nameController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '이름',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(Icons.person_outline_sharp,color: Colors.black),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                      // name 입력되었는지 확인
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 1
                          ? '이름을 입력해 주세요'
                          : null,
                    ),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      controller: emailController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '이메일',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                      // email 중복 확인
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? '유효한 이메일을 입력해 주세요'
                          : null,
                    ),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      controller: passwordController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(Icons.password_outlined, color: Colors.black),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                      obscureText: true,

                      // password 유효한지 확인
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 6
                          ? '6글자 이상 입력해주세요'
                          : null,
                    ),
                    SizedBox(height: height*0.06),
                    ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        backgroundColor: Color(0xFF74B29E),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                      ),
                      child: Text('회원가입', style: TextStyle(fontSize: width * 0.045,  color: Colors.white),),
                    ),
                    SizedBox(height: height*0.02),
                    RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: width * 0.036),
                            text: '이미 계정이 있으신가요?   ',
                            children: [
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = widget.onClickedSignUp,
                                  text: '로그인',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: width * 0.036,
                                    fontWeight:FontWeight.bold,
                                  )
                              )
                            ]
                        )
                    )
                  ],
                ),
              )
          ),
        )
    );
  }



  Future signUp() async {
    final isValid = formKey.currentState!.validate();

    if(!isValid) return;

    showDialog(
        context: this.context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    try {
      // Create user in Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Associate user data with user ID in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        // add more fields here for additional user data
      });

    } on FirebaseException catch (e) {
      print(e);
      SnackBarWidget.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }


}
