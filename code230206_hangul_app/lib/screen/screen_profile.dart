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
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: "Current Password"),
                obscureText: true,
                onChanged: (value) => currentPassword = value,
              ),
              TextField(
                decoration: InputDecoration(hintText: "New Password"),
                obscureText: true,
                onChanged: (value) => newPassword = value,
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
                      content: Text("Password updated successfully")));
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch (e) {
                  // Show an error message if there was a problem updating the password
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Failed to update password: ${e.message}")));
                }
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
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
      appBar: AppBar(
        backgroundColor: Color(0xFFF3F3F3),
        elevation: 0.0,
        title: Text(
          "I HANGUL",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: _auth.currentUser!.email,
                decoration: InputDecoration(
                  labelText: "이메일",
                  border: OutlineInputBorder(),
                ),
                enabled: false,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "이름",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "이름을 입력해주세요";
                  }
                  return null;
                },
                style: TextStyle(fontSize: 24),
              ),
              Expanded(
                child: Container(),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: width * 0.5,
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
                  child: Text("변경사항 저장",
                    style: TextStyle(fontSize: 20, color: Colors.black),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFF3F3F3)),
                  ),
                )
              ),
              SizedBox(height: 16),
              SizedBox(
                width: width * 0.5,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showChangePasswordDialog,
                  child: Text("비밀번호 변경",
                    style: TextStyle(fontSize: 20, color: Colors.black),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFF3F3F3)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: width * 0.5,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  child: Text("로그아웃",
                    style: TextStyle(fontSize: 20, color: Colors.black),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFF3F3F3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



