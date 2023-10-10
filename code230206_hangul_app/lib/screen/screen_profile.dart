// *** 회원정보 스크린 ***
// 가입할 때 입력한 email, name을 보여주는 스크린
// email은 ID라 수정 불가, name은 수정 가능
// 비밀번호 변경 버튼 클릭 -> 현재 비밀번호, 새 비밀번호 입력 -> 비밀번호 변경

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_auth_Login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentPassword = "";
        String newPassword = "";

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            "비밀번호 변경",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF74b29e),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "현재 비밀번호",
                  filled: true,
                  fillColor: Colors.white, // 바탕색 설정
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.white), // 테두리선 색상 설정
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.white), // 테두리선 색상 설정
                  ),
                ),
                obscureText: true,
                onChanged: (value) => currentPassword = value,
                cursorColor: Colors.black,
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "새 비밀번호",
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
                onChanged: (value) => newPassword = value,
                cursorColor: Colors.black,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Re-authenticate the user to verify their current password
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: _auth.currentUser!.email!,
                    password: currentPassword,
                  );
                  await _auth.currentUser!
                      .reauthenticateWithCredential(credential);

                  // Update the user's password
                  await _auth.currentUser!.updatePassword(newPassword);

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Password updated successfully"),
                  ));
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch (e) {
                  // Show an error message if there was a problem updating the password
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to update password: ${e.message}"),
                  ));
                }
              },
              child: Text("저장",style: TextStyle(
                  color: Colors.white,fontSize: 16),),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소",style: TextStyle(
                  color: Colors.white,fontSize: 16),),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final userData = userSnapshot.data() as Map<String, dynamic>;
    _nameController.text = userData['name'];
  }

  void _updateUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userData = {'name': _nameController.text};
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update(userData);
  }

  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xffd9ebe5),
      appBar: AppBar(
        backgroundColor: Color(0xffd9ebe5),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Tooltip(
              richMessage: WidgetSpan(
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: const Text("프로필 화면",
                          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: const Text("회원가입 시 입력했던 이메일과 이름을 확인해요. 이름과 비밀번호를 변경할 수 있어요.",
                            style: TextStyle(color: Colors.black, fontSize: 14)),
                      )
                    ],
                  )
              ),
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: Color(0xFF74b29e), // Border color
                  width: 1.0, // Border width
                ),
              ),
              child: Icon(Icons.help_outline, color: Colors.black,),
            ),
            onPressed: () {},
          ),
        ],
        //title: Text("I HANGUL",style: TextStyle(color: Colors.black,),),
        //centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 수평으로 중앙 정렬
                  children: [
                    SizedBox(
                      width: width * 0.84,
                      height: 60,
                      child: TextFormField(
                        initialValue: _auth.currentUser!.email,
                        decoration: InputDecoration(
                          labelText: "이메일",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                              //width: 2.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        enabled: false,
                        style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold,),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.84,
                      height: 60,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "이름",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                          errorStyle: TextStyle(fontSize: 16),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "이름을 입력해주세요";
                          }
                          return null;
                        },
                        style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold,),
                        cursorColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 55),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.84,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _updateUserName();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("수정되었습니다"),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          primary: Color(0xFF74B29E),
                        ),
                        child: Text(
                          "이름 변경",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 수평으로 중앙 정렬
                  children: [
                    SizedBox(
                      width: width * 0.84,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          primary: Color(0xFF74B29E),
                        ),
                        child: Text(
                          "비밀번호 변경",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.84,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          primary: Color(0xFF74B29E),
                        ),
                        child: Text(
                          "로그아웃",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}