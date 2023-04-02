import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ConsonantGame());
}

class ConsonantGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '초성 게임',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int randomSend = 0;
  String _buttonText = 'hint 받기';

  final vocabularyList = VocabularyList(
    vocabularies: [
      Vocabulary(
        word: '사과',
        mean: '과일사과',
        consonant: 'ㅅㄱ',
      ),
      Vocabulary(
        word: '바나나',
        mean: '과일바나나',
        consonant: 'ㅂㄴㄴ',
      ),
      Vocabulary(
        word: '딸기',
        mean: '과일딸기',
        consonant: 'ㄸㄱ',
      ),
      Vocabulary(
        word: '포도',
        mean: '과일포도',
        consonant: 'ㅍㄷ',
      ),
      Vocabulary(
        word: '오렌지',
        mean: '과일오렌지',
        consonant: 'ㅇㄹㅈ',
      ),
    ],
  );

  int timesController = 0;
  final _controller = TextEditingController();
  String _currentWord = '';

  @override
  void initState() {
    super.initState();
    getCorrectAnswer();
  }

  void getCorrectAnswer() {
    setState(() {
      //초기화
      randomSend = new Random().nextInt(vocabularyList.length);
      _currentWord = vocabularyList[randomSend].consonant;
      _controller.clear();
      _buttonText = 'hint 받기';
      timesController = 0;
    });
  }

  getWorongAnswer() {
    timesController++;
    if (timesController >= 2) {
      getCorrectAnswer();
    }
  }

  setHint() {
    _buttonText = vocabularyList[randomSend].mean;
  }

  bool _checkAnswer(String input) {
    return isKorean(input) &&
        _controller.text == vocabularyList[randomSend].word;
  }

  bool isKorean(String str) {
    final regex = RegExp('[\\uAC00-\\uD7AF]+');
    return regex.hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('초성 게임'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _currentWord,
            style: TextStyle(
              fontSize: 48,
              letterSpacing: 32,
            ),
          ),
          SizedBox(height: 64),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: '정답을 입력해주세요.', hintStyle: TextStyle(fontSize: 24)),
            textAlign: TextAlign.center,
            onSubmitted: (input) {
              if (_checkAnswer(input)) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('정답'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/right.png',
                              width: 100,
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                getCorrectAnswer();
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('틀려요'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/wrong.png',
                              width: 100,
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                getWorongAnswer();
              }
            },
          ),
          SizedBox(height: 64),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/key_color.png',
                  height: 50,
                  width: 50,
                ),
                SizedBox(width: 32),
                TextButton(
                  child: Text(
                    _buttonText,
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                  onPressed: () {
                    setState(setHint);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Vocabulary {
  String word;
  String mean;
  String consonant;

  Vocabulary({required this.word, required this.mean, required this.consonant,});

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      word: json['word'],
      mean: json['mean'],
      consonant: json['consonant'],
    );
  }
}

class VocabularyList {
  final List<Vocabulary> _vocabulary;

  VocabularyList({required List<Vocabulary> vocabularies}) : _vocabulary = vocabularies;

  int get length => _vocabulary.length;

  Vocabulary operator [](int index) => _vocabulary[index];
}


