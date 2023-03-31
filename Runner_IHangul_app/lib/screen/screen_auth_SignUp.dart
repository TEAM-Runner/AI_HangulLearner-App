// *** sign up 스크린 ***

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:runner_IHangul_app/main.dart';
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
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline_sharp),
                          border: OutlineInputBorder()
                      ),

                      // name 입력되었는지 확인
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 1
                          ? 'Enter your name'
                          : null,
                    ),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      controller: emailController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder()
                      ),

                      // email 중복 확인
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Enter a valid email'
                          : null,
                    ),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      controller: passwordController,
                      // cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.password_outlined),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              // color: Colors.deepPurple,
                              // width: 2
                            ),
                          ),
                          border: OutlineInputBorder()
                      ),
                      obscureText: true,

                      // password 유효한지 확인
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 6
                          ? 'Enter min. 6 characters'
                          : null,
                    ),
                    SizedBox(height: height*0.06),
                    ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                          backgroundColor: Colors.deepPurple),
                      child: Text('SignUp', style: TextStyle(fontSize: width * 0.045),),
                    ),
                    SizedBox(height: height*0.02),
                    RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: width * 0.036),
                            text: 'Already have an account?   ',
                            children: [
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = widget.onClickedSignUp,
                                  text: 'Log In',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.deepPurple,
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
