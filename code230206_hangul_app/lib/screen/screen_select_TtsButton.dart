import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screen_select_modifyButton.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

int currentTTSIndex = 0; // 현재 TTS 출력 중인 인덱스 0으로 초기화

class Word {
  String word; // 단어
  bool isSelected; // highlight 표시 여부
  int sentenceIndex; // 단어가 포함된 문장 인덱스
  int wordIndex; // 텍스트 전체에서 단어 인덱스
  int wordIndexInSentence; // 단어가 포함된 문장에서 단어 인덱스
  Word({required this.word, this.isSelected = false, required this.sentenceIndex, required this.wordIndex, required this.wordIndexInSentence});
}

// TTS 화면 문장별 표시를 위한 Sentence 클래스
class Sentence {
  int wordIndex;
  List<Word> words; // Word들을 속성으로 가짐
  Sentence({required this.wordIndex, required this.words});
}


class SelectTtsButtonScreen extends StatefulWidget {
  final String text;
  late int initialTTSIndex;  //현재 TTS 출력 중인 인덱스 전달(기록용)

  SelectTtsButtonScreen({required this.text,  required this.initialTTSIndex});

  @override
  _SelectTtsButtonScreenState createState() => _SelectTtsButtonScreenState(text);
}

class _SelectTtsButtonScreenState extends State<SelectTtsButtonScreen> {
  String _text; // 이전 화면에서 받아온 텍스트
  List<Word> wordList = [];
  List<Sentence> sentenceList = []; // Sentences 클래스 리스트 저장

  List<String> _sentences = [];
  int _currentSentenceIndex = -1; // 현재 문장의 인덱스 표시 (처음 아무것도 선택X -> -1)
  List<double> _ttsSpeed = [0.2, 0.4, 0.6, 0.8, 1.0]; // tts 속도 저장 리스트. 느림 - 보통 - 빠름
  final FlutterTts _tts = FlutterTts(); // tts
  int _ttsSpeedIndex = 2; // _ttsSpeed 리스트의 인덱스 저장
  // StreamController<List<Word>> _streamController = StreamController<List<Word>>.broadcast();
  // Stream<List<Word>> get stream => _streamController.stream;
  StreamController<List<Sentence>> _streamController = StreamController<List<Sentence>>.broadcast();
  Stream<List<Sentence>> get stream => _streamController.stream;

  bool _stopflag = true; // TTS speak or not
  bool _playflag = false; // TTS stop or play

  // dictionary *************************************
  String? _dic_selectedWord; // dictionary string
  // firestore 단어 저장 부분
  late User? user;
  late DocumentReference userRef;
  late CollectionReference wordsRef;

  List<dicWord> dicWords = [];
  List<bool> _starred = [];

  List<bool> _iconPlayFlags = []; // IconButton의 아이콘 제어 위한 리스트
  StreamController<bool> _streamIconController = StreamController<bool>.broadcast();
  Stream<bool> get iconstream => _streamIconController.stream;




  int _toggleSwitchvalue = 1; // tts 속도를 지정하는 토글 스위치 인덱스
  List<String> _speaktype = ["one", "all", "record"];

  // init
  _SelectTtsButtonScreenState(this._text) {
    _text = _text.replaceAll('\n', ' ');
    _sentences = _text.split(RegExp('(?<=[.!?])\\s*')); // 문장 리스트 -> '.', '?', '!' 문장 단위로 split

    int wordIndex = -1;

    // TTS 화면 문장별 표시를 위한 Sentence 클래스 관련
    int sentenceIndex = 0;
    Sentence currentSentence = Sentence(wordIndex: sentenceIndex, words: []);

     for (int i = 0; i < _sentences.length; i++) {
      final words = _sentences[i].trim().split(' ');
      for (int j = 0; j < words.length; j++) {
        Word newWord = Word(
          word: words[j],
          sentenceIndex: i,
          wordIndex: ++wordIndex,
          wordIndexInSentence: j,
        );
        wordList.add(newWord);

        currentSentence.words.add(newWord); // Sentence 클래스 관련
      }

      // Sentence 클래스 관련
      sentenceIndex++; // 새 문장이 나오면 문장인덱스++
      sentenceList.add(currentSentence); // 새 문장이 나오면 currentSentence 추가
      currentSentence = Sentence(wordIndex: sentenceIndex, words: []); // Sentence 클래스 관련

    }
    _tts.setLanguage('kor'); // tts - 언어 한국어
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]);  // tts - 읽기 속도. 기본 보통 속도

    // Sentence 클래스 출력 (로그출력용)
    // for (int i = 0; i < sentenceList.length; i++) {
    //   print("Sentence ${sentenceList[i].wordIndex}:");
    //   for (int j = 0; j < sentenceList[i].words.length; j++) {
    //     print("  Word ${sentenceList[i].words[j].wordIndexInSentence}: ${sentenceList[i].words[j].word}");
    //   }
    // }


    _iconPlayFlags = List.generate(sentenceList.length, (index) => false); // IconButton의 아이콘 제어 위한 리스트
    _dic_initializeUserRef();

  }


  // original
  // void _speakWord(int sentenceIndex, int wordIndex, String speaktype) async {
  //   print("_speakWord is called");
  //   // print("_speakWord _currentSentenceIndex: $_currentSentenceIndex");
  //
  //   if (sentenceIndex != -1) {
  //     setState(() {
  //       _currentSentenceIndex = sentenceIndex;
  //       _updateIsSelected(-1);
  //     });
  //     int sentenceFirstIndex = 0;
  //     int sentenceLastIndex = 0;
  //
  //     if (speaktype == "one"){
  //       for (int i = 0; i < wordList.length; i++) {
  //         if (wordList[i].sentenceIndex == sentenceIndex) {
  //           sentenceFirstIndex =  wordList[i].wordIndex;
  //           break;
  //         }
  //       }
  //
  //       for (int i = wordList.length - 1; i >= 0; i--) {
  //         if (wordList[i].sentenceIndex == sentenceIndex) {
  //           sentenceLastIndex = wordList[i].wordIndex;
  //           break;
  //         }
  //       }
  //     }
  //     if (speaktype == "all") {
  //       sentenceFirstIndex = 0;
  //       sentenceLastIndex = wordList.length - 1;
  //       print("_speakWord sentenceFirstIndex: $sentenceFirstIndex");
  //
  //     }
  //
  //     // TTS 기록이 존재하는 경우
  //     // int sentenceIndex = 0으로, int wordIndex = currentTTSindex으로, String speaktype="currentTTSindex"으로 지정
  //     if (speaktype == "record") {
  //       sentenceFirstIndex = wordIndex;
  //       sentenceLastIndex = wordList.length - 1;
  //     }
  //     _speakSentence(sentenceFirstIndex, sentenceLastIndex);
  //   }
  // }

  void _speakWord(int sentenceIndex, int wordIndex, String speaktype) async {
    print("_speakWord is called");
    // print("_speakWord _currentSentenceIndex: $_currentSentenceIndex");

    if (sentenceIndex != -1) {
      setState(() {
        _currentSentenceIndex = sentenceIndex;
        // _updateIsSelected(-1);
      });
      int sentenceFirstIndex = 0;
      int sentenceLastIndex = 0;

      if (speaktype == "one"){
        for (int i = 0; i < wordList.length; i++) {
          if (wordList[i].sentenceIndex == sentenceIndex) {
            sentenceFirstIndex =  wordList[i].wordIndex;
            break;
          }
        }

        for (int i = wordList.length - 1; i >= 0; i--) {
          if (wordList[i].sentenceIndex == sentenceIndex) {
            sentenceLastIndex = wordList[i].wordIndex;
            break;
          }
        }
      }
      if (speaktype == "all") {
        sentenceFirstIndex = 0;
        sentenceLastIndex = wordList.length - 1;
        print("_speakWord sentenceFirstIndex: $sentenceFirstIndex");

      }

      // TTS 기록이 존재하는 경우
      // int sentenceIndex = 0으로, int wordIndex = currentTTSindex으로, String speaktype="currentTTSindex"으로 지정
      if (speaktype == "record") {
        sentenceFirstIndex = wordIndex;
        sentenceLastIndex = wordList.length - 1;
      }
      _speakSentence(sentenceFirstIndex, sentenceLastIndex);
    }
  }

  void _speakSentence(int sentenceFirstIndex, int sentenceLastIndex) async {
    print("_speakSentence is called");

    setState(() {
      // _updateIsSelected(-1);
    });

    // E/flutter ( 7310): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: setState() called after dispose(): _SelectTtsButtonScreenState#5560a(lifecycle state: defunct, not mounted)
    // 위 오류 때문에 추가
    if (!mounted) return; // Check if the widget is still mounted

    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // tts - 읽기 속도
    await _tts.awaitSpeakCompletion(true);

    for (int i = sentenceFirstIndex; i <= sentenceLastIndex; i++){
      // _updateIsSelected(i);

      if (_stopflag) {
        _playflag = true;
        await _tts.speak(wordList[i].word);
        currentTTSIndex = i;//현재 TTS 출력 중인 인덱스 기록
        if (i == sentenceLastIndex) { currentTTSIndex = 0; } //마지막까지 출력한 경우 TTS 인덱스 다시 0
      }

      if (_currentSentenceIndex == -1){
        break;
      }
      // _updateIsSelected(i);
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {});
    }
    _playflag = false;
    // _updateIsSelected(-1);
  }

  // 문장 옆의 재생 버튼 누르는 경우, 해당 문장만 읽어줌
  void _speakOneSentence (int sentenceIndex, Sentence sentence) async {

    setState(() {
      _updateIsSelected(-1, -1);
    });

    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // tts - 읽기 속도
    await _tts.awaitSpeakCompletion(true);

    for (int wordIndex = 0; wordIndex < sentence.words.length; wordIndex++) {
      _updateIsSelected(sentenceIndex, wordIndex);

      // final word = sentence.words[wordIndex].word;
      if (_stopflag) {
        _playflag = true;
        await _tts.speak(sentence.words[wordIndex].word);
      }
    }

    _playflag = false;
    _updateIsSelected(-1,-1);
  }


  void _updateIsSelected(int highlightSentenceIndex, int highlightWordIndexInSentence) {
    for (final sentence in sentenceList) {
      for (final word in sentence.words) {
        word.isSelected = false;
        _streamController.add(sentenceList);
        _streamIconController.add(true); // Stop speaking
      }
    }

    if (highlightSentenceIndex != -1 && highlightWordIndexInSentence != -1) {
      sentenceList[highlightSentenceIndex].words[highlightWordIndexInSentence].isSelected = true;
      // print("${sentenceList[highlightSentenceIndex].words[highlightWordIndexInSentence].word}: ${sentenceList[highlightSentenceIndex].words[highlightWordIndexInSentence].isSelected}");
      _streamController.add(sentenceList);
      _streamIconController.add(false); // Stop speaking

    }
  }


  void _stopSpeakTts() async {
    // _stopflag = false;
    await _tts.stop();
  }

  Widget alternativeIconBuilder(BuildContext context, SizeProperties<int> local,
      GlobalToggleProperties<int> global) {
    IconData data = Icons.access_time_rounded;
    switch (local.value) {
      case 0: // TTS 속도 빠르게
        data = Icons.arrow_forward_ios;
        break;
      case 1: // TTS 속도 보통
        data = Icons.play_arrow_outlined;
        break;
      case 2: // TTS 속도 느리게
        data = Icons.arrow_back_ios;
        break;
    }
    return Icon(
      data,
      size: local.iconSize.shortestSide,
    );
  }

  // ********** dictionary function **********
  // _dic 붙은 함수는 screen_select_dicButton에 있던 함수
  // showModalBottomSheet에서 star icon 상태 업데이트 위한 함수
  void _dic_initializeUserRef() {
    user = FirebaseAuth.instance.currentUser;
    userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    wordsRef = userRef.collection('words');

  }
  void _dic_toggleStarred(int index) async {
    String word = dicWords[index].txt_emph;
    DocumentSnapshot snapshot = await wordsRef.doc(word).get();
    setState(() {
      _starred[index] = !_starred[index];
    });

    if (_starred[index]) {
      // timestamp
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      wordsRef.doc(word).set({
        'word': dicWords[index].txt_emph,
        'meaning': dicWords[index].txt_mean,
        'timestamp': formattedDate, // Add timestamp
      }); // Firestore에 단어가 없을 경우 추가
    } else {
      wordsRef.doc(word).delete(); // Firestore에서 단어 삭제
    }
  }
  bool _dic_isSelected(String word) {
    return _dic_selectedWord == word;
  }

  void _dic_toggleSelected(String word) {
    setState(() {
      if (_dic_selectedWord == word) {
        _dic_selectedWord = null;
      } else {
        _dic_selectedWord = word;
      }
    });
  }

  void _dic_showPopup(String word) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Color(0xFFEFEFEF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        // final webScraper = WebScraper(word);
        final WebScraper webScraper = WebScraper('$word');

        return SizedBox(
          height: 300,
          child: StatefulBuilder(
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
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: dicWords.length,
                          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10),
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
                                return Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Container(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // add tts or ... tts 보류
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.white,
                                        onPrimary: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),                                    ),
                                      child: Padding(
                                        padding: EdgeInsets.all(1),
                                        child: ListTile(
                                          title: Text(dicWords[index].txt_emph,
                                              style: const TextStyle(fontSize: 24)),
                                          subtitle: Text(dicWords[index].txt_mean,
                                              style: const TextStyle(fontSize: 20)),
                                          trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _dic_toggleStarred(index);
                                              });
                                            },
                                            icon: Icon(_starred[index] ? Icons.star : Icons.star_border,
                                              color: Colors.amber,),),
                                        ),
                                      ),
                                    ),
                                  ),
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
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;


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
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Color(0xFFC0EB75),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(
                          builder: (context) => SelectModifyButtonScreen(text: _text, initialTTSIndex: currentTTSIndex,),
                        ),
                      );
                    },
                    icon: Icon(Icons.border_color_outlined, color: Colors.black),
                  ),
                )


              ],
            ),
            SizedBox(height: 16.0),

            //original
            Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sentenceList.length,
                  itemBuilder: (BuildContext context, int sentenceIndex) {
                    Sentence sentence = sentenceList[sentenceIndex];

                    List<String> words = sentence.words.map((word) => word.word).toList();


                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        IconButton(
                          onPressed: () {
                            setState(() {
                              _playflag = !_playflag;
                              for (int i = 0; i <
                                  _iconPlayFlags.length; i++) {
                                _iconPlayFlags[i] =
                                false; // Initialize each element to false
                              }
                            });
                            if (_playflag) {
                              _stopflag = true;
                              _speakOneSentence(sentenceIndex, sentence); // 한 문장만 읽기
                            } else {
                              _stopflag = false; // Stop all TTS
                              _stopSpeakTts(); // Stop ongoing TTS
                            }

                            if (_playflag && _stopflag){
                              _iconPlayFlags[sentenceIndex] = true;
                            } else {
                              _iconPlayFlags[sentenceIndex] = false;
                            }
                            print("_stopflag: $_stopflag       _playflag: $_playflag");

                          },
                          icon: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFC0EB75),
                            ),
                            // padding: EdgeInsets.all(8.0),
                            child: _iconPlayFlags[sentenceIndex]
                                ? Icon(Icons.stop, color: Colors.black)
                                : Icon(Icons.play_arrow, color: Colors.black),
                          ),
                        ),


                        Expanded(
                            child: Wrap(
                              spacing: 2.0,
                              runSpacing: 2.0,
                              children: sentenceList[sentenceIndex].words.asMap().entries.map((entry) {
                                int index = entry.key;
                                return StreamBuilder(
                                    stream: _streamController.stream,
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                      // tts 하이라이트 처리
                                      // List<Word> isSelected = snapshot.data ?? List<Word>.generate(wordList.length, (_) => Word(word: "", isSelected: false, sentenceIndex: -1, wordIndex: -1, wordIndexInSentence: -1));

                                      List<Sentence> isSelected_sentence = List<Sentence>.generate(sentenceList.length, (index) {
                                        // Generate a list of Word objects with default values
                                        List<Word> defaultWords = List<Word>.generate(
                                          sentenceList[index].words.length,
                                              (_) => Word(
                                            word: "",
                                            isSelected: false,
                                            sentenceIndex: -1,
                                            wordIndex: -1,
                                            wordIndexInSentence: -1,
                                          ),
                                        );

                                        return Sentence(
                                          wordIndex: -1, // You may need to set this to the actual value you want.
                                          words: defaultWords,
                                        );
                                      });

                                      return GestureDetector(
                                        onTap: () {
                                          _dic_showPopup(entry.value.word);
                                          // tts 하이라이트 처리와 사전 하이라이트 처리가 달라야 함
                                          // _dic_toggleSelected(entry.value.word);
                                          // if (_dic_isSelected(entry.value.word)) {
                                          //   _dic_showPopup(entry.value.word);
                                          // }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(2.0),
                                          decoration: BoxDecoration(
                                            color: sentenceList[sentenceIndex].words[index].isSelected ? Colors.yellow : null,
                                            // color: isSelected_sentence[sentenceIndex].words[index].isSelected ? Colors.yellow : null, // tts 하이라이트처리
                                            // color: dic_isSelected ? Colors.yellow : null, // tts 하이라이트 처리와 사전 하이라이트 처리가 달라야 함
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text(entry.value.word, style: TextStyle(fontSize: width * 0.045),), // 문장 단위 띄어쓰기 없이 나열
                                        ),
                                      );
                                    }
                                );
                              }).toList(),
                            )
                        )
                      ],
                    );


                  },
                  separatorBuilder: (BuildContext ctx, int idx) {
                    return Divider();
                  },
                ),
            ),




            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _playflag = !_playflag;
                      });
                      if (_playflag) {
                        _stopflag = true;

                        // TTS 기록이 존재하는 경우 팝업창 보여줌
                        if (currentTTSIndex != 0){ // TTS 기록이 존재하는 경우
                          showDialog( // 팝업창 띄우기
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("이어서 재생하시겠습니까?"),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text("네", style: TextStyle(color: Colors.black,),),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _speakWord(0, currentTTSIndex, _speaktype[2]); // 기록된 부분부터 끝까지 TTS 출력
                                        print("1 / TTS record is $currentTTSIndex");
                                      }
                                  ),
                                  TextButton(
                                      child: Text("아니요", style: TextStyle(color: Colors.black,),),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _speakWord(0, 0, _speaktype[1]); // 처음부터 끝까지 전체 텍스트 TTS 출력
                                        print("0 / TTS record is $currentTTSIndex");
                                      }
                                  )
                                ],
                              );
                            },
                          );

                          }
                        if (currentTTSIndex == 0){ // TTS 기록이 존재하지 않는 경우
                          _speakWord(0, 0, _speaktype[1]); // 처음부터 끝까지 전체 텍스트 TTS 출력
                          print("0 / TTS record is $currentTTSIndex");

                        }

                      } else {
                        _stopflag = false; // Stop all TTS
                        _stopSpeakTts(); // Stop ongoing TTS
                      }
                    },
                    child: _playflag
                        ? Icon(Icons.stop, color: Colors.black)
                        : Icon(Icons.volume_up_outlined, color: Colors.black),
                    backgroundColor: Color(0xFFC0EB75),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),

                AnimatedToggleSwitch<int>.size(
                  // textDirection: TextDirection.rtl, // 왜 에러뜨지...
                  current: _toggleSwitchvalue,
                  values: const [0, 1, 2],
                  // iconOpacity: 0.2,
                  // indicatorSize: const Size.fromWidth(100),
                  customIconBuilder: (context, local, global) {
                    switch (_toggleSwitchvalue) {
                      case 0: // TTS 속도 느리게
                        _ttsSpeedIndex = 2;
                        break;
                      case 1: // TTS 속도 보통
                        _ttsSpeedIndex = 1;
                        break;
                      case 2: // TTS 속도 빠르게
                        _ttsSpeedIndex = 0;
                        break;
                      default: // 기본 - TTS 속도 보통
                        _ttsSpeedIndex = 1;
                        break;
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        alternativeIconBuilder(context, local, global),
                      ],
                    );
                  },
                  borderColor: Color(0xFFC0EB75),
                  colorBuilder: (i) => i.isEven ? Color(0xFFC0EB75) : Color(0xFFC0EB75),
                  onChanged: (i) => setState(() =>
                  _toggleSwitchvalue = i,
                  ),
                ),

                Expanded(
                  child: Container(),
                ),
              ],
            ),
            SizedBox(height: 16.0),

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

    final initialUrl =
        "https://dic.daum.net/search.do?q=${Uri.encodeComponent(searchWord)}&dic=kor";
    var response = await http.get(Uri.parse(initialUrl));

    final RegExp expSupid = RegExp('supid=(.*?)[\'"]');
    final RegExp expWordid = RegExp('wordid=(.*?)[\'"]');

    final matchSupid = expSupid.firstMatch(response.body);
    final supid = matchSupid?.group(1);
    final matchWordid = expWordid.firstMatch(response.body);
    final wordid = matchWordid?.group(1);

    final finalUrl =
        'https://dic.daum.net/word/view.do?wordid=$wordid=${Uri.encodeComponent(searchWord)}&supid=$supid';
    debugPrint('finalUrl: $finalUrl');

    response = await http.get(Uri.parse(finalUrl));
    final dicWords = <dicWord>[];

    if (response.statusCode == 200) {
      final html = parser.parse(response.body);
      final container = html.querySelectorAll('.inner_top');

      // timeStamp
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      for (final element in container) {
        // ver3 -> 한 개 뜻이 있는 경우
        final txt_emph = element.querySelector('.txt_cleanword')?.text?.trim();
        final txt_mean = element.querySelector('.txt_mean')?.text?.trim();
        //.clean_word .tit_cleantype2 .txt_cleanword

        if (txt_emph != null && txt_mean != null) {
          // final word = dicWord(txt_emph: txt_emph, txt_mean: txt_mean, timestamp: formattedDate);
          dicWords.add(dicWord(txt_emph: txt_emph, txt_mean: txt_mean, timestamp: formattedDate));
        }
      }
    }

    return dicWords;
  }
}

class dicWord {
  String txt_emph = 'init';
  String txt_mean = 'init';
  String timestamp = '';

  dicWord({required this.txt_emph, required this.txt_mean, required this.timestamp});
}
