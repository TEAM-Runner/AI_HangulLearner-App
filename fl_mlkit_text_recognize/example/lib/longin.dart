import 'package:flutter/material.dart';
import 'package:example/main.dart';
import 'package:flutter_waya/flutter_waya.dart';

import 'common/assets.dart';
import 'common/widgets.dart';

main() {
  runApp(const ExtendedWidgetsApp(
    home: LoginPage(),
  ));
}

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 账号输入是否有效
  bool isUserNameValid = false;
  bool isPasswordValid = false;
  String userName = "";
  String password = "";

//登录成功后跳转到主页
  goToMainPage() {
    showToast('$userName $password');
    if (isUserNameValid && isPasswordValid) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AppPage()));
    }
  }

  // 登录表单
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username or E-Mail
          const Text(
            "계정",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff838383),
              fontWeight: FontWeight.w300,
            ),
          ),
          TextField(
            onChanged: (value) {
              bool valid = false;
              if (value.length >= 6 && value == '123456') {
                valid = true;
              } else {
                valid = false;
              }
              setState(() {
                isUserNameValid = valid;
                userName = value;
              });
            },
            decoration: InputDecoration(
              hintText: "ID or email",
              prefixIcon: Image.asset(
                AssetsImages.iconUserPng,
                width: 23,
                height: 23,
              ),
              suffixIcon: isUserNameValid == true
                  ? const Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  : null,
            ),
          ),

          // 间距
          const SizedBox(height: 35),

          // Password
          const Text(
            "비밀번호",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff838383),
              fontWeight: FontWeight.w300,
            ),
          ),
          TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "6 자리",
                prefixIcon: Image.asset(
                  AssetsImages.iconLockPng,
                  width: 23,
                  height: 23,
                ),
                suffixIcon: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forget?",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff0274bc),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                bool valid = false;
                if (value.length >= 6 && value == '123456') {
                  valid = true;
                } else {
                  valid = false;
                }
                setState(() {
                  isPasswordValid = valid;
                  password = value;
                });
              }),

          // 间距
          const SizedBox(height: 30),

          // Sign In
          ButtonWidget(
            text: 'Log in',
            onPressed: () {
              goToMainPage();
            },
            height: 60,
            widget: double.infinity,
            radius: 18,
          ),

          // 间距
          const SizedBox(height: 16),

          // Don’t have an account?  + Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 文字
              const Text(
                "약관의 확인하세요",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w300,
                ),
              ),
              //文字2
              // 按钮
              TextButton(
                onPressed: () {},
                child: const Text(
                  "동의",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff0274bc),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("회원 가입",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w300,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // 主视图
  Widget _buildView() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 100, 15, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Image.asset(
            AssetsImages.logoPng,
            width: 100,
          ),

          const SizedBox(height: 10),

          // 主标
          const Text(
            "아이 한글",
            style: TextStyle(
              fontSize: 50,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 子标
          const Text(
            "아이 한글 오신 것을 화영합니다.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 50),

          // 表单
          _buildForm(),
        ],
      ),
    );
  }

//build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SingleChildScrollView(child: _buildView()),
    );
  }
}
