// *** login 스크린 ***

import 'package:code230206_hangul_app/configuration/my_style.dart';
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
          backgroundColor: Color(0xffd9ebe5),
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
                      decoration: InputDecoration(
                        labelText: '이메일',
                        labelStyle: TextStyle(color: Colors.black,),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
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
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(Icons.password_outlined, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: height*0.06),
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                    backgroundColor: Color(0xFF74B29E),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // 원하는 모서리 둥글기 값
                    ),),
                    child: Text('로그인', style: TextStyle(fontSize: width * 0.045, color: Colors.white),),
                  ),
                  SizedBox(height: height*0.02),
                  GestureDetector(
                    child: Text(
                      "비밀번호 찾기",
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontSize: width * 0.036,
                        fontWeight:FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    )),
                  ),
                  SizedBox(height: height*0.01),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: width * 0.036,),
                          text: '계정이 없으신가요?   ',
                          children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = widget.onClickedSignUp,
                                text: '회원가입',
                                style: TextStyle(
                                  fontWeight:FontWeight.bold,
                                  //decoration: TextDecoration.underline,
                                  // color: Colors.deepPurple,
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
      String errorMessage;

      print("e: ${e}");
      print("e.message: ${e.message}");

      switch (e.message) {
        case 'The email address is badly formatted.':
          errorMessage = '이메일 형식이 잘못되었습니다.';
          break;
        case 'Unable to establish connection on channel.':
          errorMessage = '이메일과 비밀번호를 입력해 주세요.';
          break;
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorMessage = '등록되지 않은 이메일이거나 이메일을 잘못 입력했습니다.';
          break;
        case 'The password is invalid or the user does not have a password.':
          errorMessage = '비밀번호를 잘못 입력했습니다.';
          break;
        default:
          errorMessage = '일시적인 오류로 로그인을 할 수 없습니다. 잠시 후 다시 이용해 주세요.';
      }
      print("errorMessage: $errorMessage");

      // 에러 메시지 출력 팝업
      await showDialog(
          context: this.context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
              title: Center(child: Text("로그인 실패", style: TextStyle(color: Colors.white,),),),
              content: Text(errorMessage, style: TextStyle(color: Colors.white,)),
              backgroundColor: Color(0xFF74b29e),
              actions: [
                TextButton(
                  child: const Text('확인', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]
          )
      );
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
