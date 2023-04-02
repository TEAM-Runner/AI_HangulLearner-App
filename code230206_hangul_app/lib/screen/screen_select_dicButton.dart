import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screen_select_TtsButton.dart';
import 'screen_select_modifyButton.dart';

class SelectDicButtonScreen extends StatefulWidget {
  late String text;

  SelectDicButtonScreen({required this.text});

  @override
  _SelectDicButtonScreen createState() => _SelectDicButtonScreen(text);
}

class _SelectDicButtonScreen extends State<SelectDicButtonScreen> {
  late String _text;
  List<String> _textWordArray = [];
  String? _selectedWord;


  // firestore 단어 저장 부분
  late User? user;
  late DocumentReference userRef;
  late CollectionReference wordsRef;

  List<dicWord> dicWords = [];
  List<bool> _starred = [];


  void _initializeUserRef() {
    user = FirebaseAuth.instance.currentUser;
    userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    wordsRef = userRef.collection('words');
  }

  @override
  void initState() {
    super.initState();
    _initializeUserRef();
    _starred = List.generate(dicWords.length, (_) => false);
    // updateStarredList();

  }

  void _toggleStarred(int index) async {
    String word = dicWords[index].txt_emph;
    DocumentSnapshot snapshot = await wordsRef.doc(word).get();
    bool isStarred = snapshot.exists;
    // setState(() {
    //   _starred[index] = !isStarred; // toggle the value of _starred at index
    // });
    // print('***  _starred  *** ' + _starred.toString());
    // if (isStarred) {
    //   await  wordsRef.doc(word).set({'word': dicWords[index].txt_emph, 'meaning': dicWords[index].txt_mean}); // Firestore에 단어가 없을 경우 추가
    // } else {
    //   await wordsRef.doc(word).delete(); // Firestore에서 단어 삭제
    // }
    setState(() {
      _starred[index] = !_starred[index];
    });
    print('***  _starred  *** ' + _starred.toString());

    if (_starred[index]){
      wordsRef.doc(word).set({'word': dicWords[index].txt_emph, 'meaning': dicWords[index].txt_mean}); // Firestore에 단어가 없을 경우 추가
    } else {
      wordsRef.doc(word).delete(); // Firestore에서 단어 삭제
    }
  }



  _SelectDicButtonScreen(String text) {
    _text = text;
    _textWordArray = text.split(' ');
  }


  bool _isSelected(String word) {
    return _selectedWord == word;
  }

  void _toggleSelected(String word) {
    setState(() {
      if (_selectedWord == word) {
        _selectedWord = null;
      } else {
        _selectedWord = word;
      }
    });
  }

  void _showPopup(String word) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Color(0xFFD5D5D5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        // final webScraper = WebScraper(word);
        final WebScraper webScraper = WebScraper('$word');

        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder(
              future: webScraper.extractData(),
              builder: (_, snapShot) {
                if (snapShot.hasData) {
                  dicWords = snapShot.data as List<dicWord>;
                  if (_starred.length != dicWords.length) {
                    _starred = List.generate(dicWords.length, (_) => false);
                  }

                  return Column(
                    children: [
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: dicWords.length,
                        itemBuilder: (_, index) {
                          String word = dicWords[index].txt_emph;
                          return FutureBuilder<DocumentSnapshot>(
                            future: wordsRef.doc(word).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.exists) {
                                _starred[index] = true;
                              } else {
                                _starred[index] = false;
                              }

                              return Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                        onPrimary: Colors.black,
                                      ),
                                      child: ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Text(dicWords[index].txt_emph, style: const TextStyle(fontSize: 20)),
                                            ),
                                          ),
                                        ),
                                        subtitle: Text(dicWords[index].txt_mean, style: const TextStyle(fontSize: 15)),
                                        trailing: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _toggleStarred(index);
                                            });
                                          },
                                          icon: Icon(
                                            _starred[index] ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I HANGUL'),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
                ToggleSwitch(
                  initialLabelIndex: 1,
                  labels: ['수정', 'dic', 'tts'],
                  radiusStyle: true,
                  onToggle: (index) {
                    if (index == 0) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectModifyButtonScreen(text: _text),
                        ),
                      );
                    } else if (index == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectDicButtonScreen(text: _text),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectTtsButtonScreen(text: _text),
                        ),
                      );
                    }
                  },
                  minWidth: 90.0,
                  cornerRadius: 20.0,
                  activeBgColor: [Colors.deepPurple],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: Colors.black,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: _textWordArray.map((word) {
                bool isSelected = _selectedWord == word;
                return GestureDetector(
                  onTap: () {
                    _toggleSelected(word);
                    if (_isSelected(word)) {
                      _showPopup(word);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow : null,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(word),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}



// 뜻이 하나만 있는 경우: 리다이렉트 되는 새 url에서 supid, wordid를 구해 finalUrl을 정의해야 함
class WebScraper {
  final String searchWord;

  WebScraper(this.searchWord);

  Future<List<dicWord>> extractData() async {
    final initialUrl = "https://dic.daum.net/search.do?q=${Uri.encodeComponent(searchWord)}&dic=kor";
    var response = await http.get(Uri.parse(initialUrl));

    final RegExp expSupid = RegExp('supid=(.*?)[\'"]');
    final RegExp expWordid = RegExp('wordid=(.*?)[\'"]');

    final matchSupid = expSupid.firstMatch(response.body);
    final supid = matchSupid?.group(1);
    final matchWordid = expWordid.firstMatch(response.body);
    final wordid = matchWordid?.group(1);

    final finalUrl = 'https://dic.daum.net/word/view.do?wordid=$wordid=${Uri.encodeComponent(searchWord)}&supid=$supid';
    debugPrint('finalUrl: $finalUrl');

    response = await http.get(Uri.parse(finalUrl));
    final dicWords = <dicWord>[];

    if (response.statusCode == 200) {
      final html = parser.parse(response.body);

      final container = html.querySelectorAll('.inner_top');

      for (final element in container) {
        // ver3 -> 한 개 뜻이 있는 경우
        final txt_emph = element.querySelector('.txt_cleanword')?.text;
        final txt_mean = element.querySelector('.txt_mean')?.text;
        //.clean_word .tit_cleantype2 .txt_cleanword

        if (txt_emph != null && txt_mean != null) {
          dicWords.add(dicWord(txt_emph: txt_emph, txt_mean: txt_mean));
        }
      }
    }

    return dicWords;
  }
}

class dicWord {
  String txt_emph ='init';
  String txt_mean = 'init';

  dicWord(
      {required this.txt_emph, required this.txt_mean});
}
