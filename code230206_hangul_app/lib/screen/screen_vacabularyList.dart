// *** 단어장 스크린 ***
// firestore에 저장된 단어/뜻 리스트를 보여주는 스크린

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({Key? key}) : super(key: key);

  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  late User user;
  late CollectionReference wordsRef;
  List<QueryDocumentSnapshot> starredWords = [];

  void _initializeUserRef() {
    user = FirebaseAuth.instance.currentUser!;
    wordsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('words');
  }

  @override
  void initState() {
    super.initState();
    _initializeUserRef();
    _getStarredWords();
  }

  void _getStarredWords() async {
    final QuerySnapshot querySnapshot = await wordsRef.get();
    setState(() {
      starredWords = querySnapshot.docs;
    });
  }

  void _toggleWordStarred(String word) async {
    final DocumentReference wordRef = wordsRef.doc(word);
    final bool exists = await wordRef
        .get()
        .then((DocumentSnapshot snapshot) => snapshot.exists);
    if (exists) {
      await wordRef.delete();
    } else {
      await wordRef.set({'word': word});
    }
    _getStarredWords();
  }

  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;


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
        padding: EdgeInsets.all(width * 0.03),
        child: starredWords.isEmpty
            ? Center(child: const Text('단어장에 단어가 존재하지 않습니다'))
            : ListView.builder(
          itemCount: starredWords.length,
          itemBuilder: (_, index) {
            final String word = starredWords[index]['word'];
            return Card(
              child: ListTile(
                title: Text(
                  starredWords[index]['word'],
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  starredWords[index]['meaning'],
                  style: const TextStyle(fontSize: 20),
                ),
                trailing: IconButton(
                    icon: Icon(Icons.star),
                    color: Colors.orangeAccent,
                    // onPressed: () {_toggleWordStarred(word);},
                    onPressed: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: true, // 바깥 터치시 close
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('단어를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  child: const Text('아니요'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('네'),
                                  onPressed: () {
                                    _toggleWordStarred(word);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    }
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
