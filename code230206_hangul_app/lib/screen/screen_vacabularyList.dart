// *** 단어장 스크린 ***
// firestore에 저장된 단어/뜻 리스트를 보여주는 스크린

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hangul/hangul.dart';
import 'package:floating_action_bubble_custom/floating_action_bubble_custom.dart';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({Key? key}) : super(key: key);

  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen>
    with SingleTickerProviderStateMixin {
  late User user;
  late CollectionReference wordsRef;
  List<QueryDocumentSnapshot> starredWords = [];

  //FloatButton Animation
  late Animation<double> _animation;
  late AnimationController _animationController;

  //hidden
  bool _hiddenWord = false;
  bool _hiddenMeaning = false;

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

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  void _getStarredWords() async {
    final QuerySnapshot querySnapshot = await wordsRef.get();
    setState(() {
      starredWords = querySnapshot.docs;
    });
  }

  //sort word list random
  void _randomOrderStarredWords() {
    //TO DO
    setState(() {
      starredWords.shuffle(Random());
    });
  }

  //sort word list consonant order
  void _consonantOrderStarredWords() {
    //TO DO
    setState(() {
      _getStarredWords();
    });
  }

  //hide word
  void _hideWords() {
    _hiddenWord = true;
    _hiddenMeaning = false;
    setState(() {});
  }

  //hide meaning
  void _hideMeaning() {
    _hiddenWord = false;
    _hiddenMeaning = true;
    setState(() {});
  }

  //display the word and meaning
  void _fullDisplay() {
    _hiddenWord = false;
    _hiddenMeaning = false;
    setState(() {});
  }

  String _getFirstConsonant(String word) {
    final syllables = HangulSyllable.fromString(word);
    final firstConsonant = syllables.cho;
    return firstConsonant;
  }

  void _insertToStartedWords(){

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "I HANGUL",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        //Init Floating Action Bubble
        floatingActionButton: FloatingActionBubble(
          // Menu items
          items: <Widget>[
            BubbleMenu(
                title: "    Order",
                style: TextStyle(color: Color.fromARGB(255, 51, 153, 255)),
                iconColor: Color.fromARGB(255, 51, 153, 255),
                bubbleColor: Color.fromARGB(255, 255, 255, 255),
                icon: Icons.bar_chart,
                onPressed: _consonantOrderStarredWords),
            BubbleMenu(
                title: "Random",
                style: TextStyle(color: Color.fromARGB(255, 51, 153, 255)),
                iconColor: Color.fromARGB(255, 51, 153, 255),
                bubbleColor: Color.fromARGB(255, 255, 255, 255),
                icon: Icons.bar_chart,
                onPressed: _randomOrderStarredWords),
            BubbleMenu(
                title: "only meaning",
                style: TextStyle(color: Color.fromARGB(255, 255, 162, 0)),
                iconColor: Color.fromARGB(255, 255, 162, 0),
                bubbleColor: Color.fromARGB(255, 255, 255, 255),
                icon: Icons.hide_source,
                onPressed: _hideWords),
            BubbleMenu(
                title: "only words     ",
                style: TextStyle(color: Color.fromARGB(255, 255, 162, 0)),
                iconColor: Color.fromARGB(255, 255, 162, 0),
                bubbleColor: Color.fromARGB(255, 255, 255, 255),
                icon: Icons.hide_source,
                onPressed: _hideMeaning),
            BubbleMenu(
                title: "full display      ",
                style: TextStyle(color: Color.fromARGB(255, 255, 162, 0)),
                iconColor: Color.fromARGB(255, 255, 162, 0),
                bubbleColor: Color.fromARGB(255, 255, 255, 255),
                icon: Icons.hide_source,
                onPressed: _fullDisplay),
          ],

          // animation controller
          animation: _animation,

          // On pressed change animation state
          onPressed: () => _animationController.isCompleted
              ? _animationController.reverse()
              : _animationController.forward(),

          // Floating Action button Icon color
          iconColor: Colors.blue,

          // Flaoting Action button Icon
          iconData: Icons.add_circle_outline,
          backgroundColor: Colors.white,
        ),
        body: Column(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: starredWords.isEmpty
                  ? Center(child: const Text('단어장에 단어가 존재하지 않습니다'))
                  : ListView.builder(
                      itemCount: starredWords.length,
                      itemBuilder: (_, index) {
                        final String word = starredWords[index]['word'];
                        if (_hiddenWord == false && _hiddenMeaning == false) {
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
                                        barrierDismissible:
                                            true, // 바깥 터치시 close
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
                                        });
                                  }),
                            ),
                          );
                        }
                        else if (_hiddenWord == true) {
                          return Card(
                            child: ListTile(
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
                                        barrierDismissible:
                                            true, // 바깥 터치시 close
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
                                        });
                                  }),
                            ),
                          );
                        }
                        else if (_hiddenMeaning == true) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                starredWords[index]['word'],
                                style: const TextStyle(fontSize: 20),
                              ),
                              trailing: IconButton(
                                  icon: Icon(Icons.star),
                                  color: Colors.orangeAccent,
                                  // onPressed: () {_toggleWordStarred(word);},
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        barrierDismissible:
                                            true, // 바깥 터치시 close
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
                                        });
                                  }),
                            ),
                          );
                        }
                      },
                    ),
            ),
          )
        ]));
  }
}
