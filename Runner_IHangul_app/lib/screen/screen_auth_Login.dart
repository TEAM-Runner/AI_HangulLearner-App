// *** login 스크린 ***

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:runner_IHangul_app/main.dart';
import 'screen_home.dart';
import 'snackBarWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:email_validator/email_validator.dart';
import 'screen_auth_Login.dart';
import 'screen_auth_SignUp.dart';
import 'screen_auth_authPage.dart';
import 'screen_auth_forgotPassword.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // 대기 중일 때
          return Center(child: CircularProgressIndicator()); // -> Circular 대기 모양 표시
        } else if (snapshot.hasError) { // Error가 발생했을 때
          return Center(child: Text('Error')); // -> 에러 표시
        } else if (snapshot.hasData) { // 데이터가 있을 때 (정상적으로 입력되었을 때)
          return HomeScreen(); // -> HomeScreen으로 이동
        } else { // 데이터가 없을 때 (정상적으로 입력되지 않았을 때)
          return AuthPageScreen(); // -> 페이지 이동 X
        }
      },
    ),
  );
}

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginWidget createState() => _LoginWidget();
}

class _LoginWidget extends State<LoginWidget> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.2),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.black,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        // labelStyle: TextStyle(color: Colors.black54),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                        // focusedBorder: OutlineInputBorder(
                        //   borderSide: BorderSide(
                        //       color: Colors.black54,
                        //       width: 2,
                        //   ),
                        // ),
                        border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  TextFormField(
                    controller: passwordController,
                    cursorColor: Colors.black,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.password_outlined),
                        border: OutlineInputBorder()
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: height*0.06),
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple),
                    child: Text('Login', style: TextStyle(fontSize: width * 0.045),),
                  ),
                  SizedBox(height: height*0.02),
                  GestureDetector(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.deepPurple,
                        fontSize: width * 0.036,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    )),
                  ),
                  SizedBox(height: height*0.01),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: width * 0.036),
                          text: 'No account?   ',
                          children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = widget.onClickedSignUp,
                                text: 'Sign Up',
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
            ),
        ),
    );
  }

  Future signIn() async {
    showDialog(
        context: this.context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
    } on FirebaseException catch (e) {
      print(e);
      SnackBarWidget.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
