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
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: width*0.15,
        title: Text("I HANGUL"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
              gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent,Colors.deepPurple],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter
              )
          ),
        ),

      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _auth.currentUser!.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserName();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Profile updated'),
                    ));
                  }
                },
                child: Text('Save'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showChangePasswordDialog,
                child: Text("Change Password"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
                child: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



