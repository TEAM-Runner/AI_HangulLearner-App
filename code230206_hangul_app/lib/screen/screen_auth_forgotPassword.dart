// *** 비밀번호 찾기 스크린 ***
// screen_login.dart에서 forgot password를 클릭하면 나오는 스크린
// 이메일을 입력하고 비밀번호를 변경할 수 있음

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      TextFormField(
                        controller: emailController,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder()
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a vaild email'
                            : null,
                      ),

                      SizedBox(height: height*0.06),
                      ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                            backgroundColor: Colors.deepPurple),
                        child: Text('Reset Password', style: TextStyle(fontSize: width * 0.045),),
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
     SnackBarWidget.showSnackBar('Password Reset Email Sent');
     Navigator.of(context).popUntil((route) => route.isFirst);
   } on FirebaseAuthException catch (e) {
      print(e);
      SnackBarWidget.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}