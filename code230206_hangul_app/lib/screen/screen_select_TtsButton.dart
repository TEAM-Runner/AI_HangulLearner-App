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
import 'screen_home.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';

bool _WebScraperFlag = false; // WebScraper 검색결과가 존재하는 경우 true, 존재하지 않는 경우 false

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
  _SelectTtsButtonScreenState createState() => _SelectTtsButtonScreenState(text, initialTTSIndex);
}

class _SelectTtsButtonScreenState extends State<SelectTtsButtonScreen> {

  String _text; // 이전 화면에서 받아온 텍스트
  int currentTTSIndex; // 현재 TTS 출력 중인 인덱스 기록

  List<Word> wordList = [];
  List<Sentence> sentenceList = []; // Sentences 클래스 리스트 저장

  List<String> _sentences = [];
  int _currentSentenceIndex = -1; // 현재 문장의 인덱스 표시 (처음 아무것도 선택X -> -1)

  final FlutterTts _tts = FlutterTts(); // tts
  List<double> _ttsSpeed = [0.3, 0.4, 0.5, 0.6, 0.7]; // tts 속도 저장 리스트. 느림 - 보통 - 빠름
  int _ttsSpeedIndex = 2; // _ttsSpeed 리스트의 인덱스 저장
  // StreamController<List<Word>> _streamController = StreamController<List<Word>>.broadcast();
  // Stream<List<Word>> get stream => _streamController.stream;
  StreamController<List<Sentence>> _streamController = StreamController<List<Sentence>>.broadcast();
  Stream<List<Sentence>> get stream => _streamController.stream;

  bool _stopflag = true; // TTS speak or not
  bool _playflag = false; // TTS stop or play
  bool _muteflag = true; // TTS mute or not
  bool _currentTTSIndexResetFlag = false; // currentTTSIndex를 reset 해야할 때 true, reset 할 필요 없을때 false
  bool _ttsSpeedChangedFlag = false; // TTS speed changed or not

  final List<String> items = [ // for tts speed - dropdown_button_2
    'X 0.5', 'X 0.75', 'X 1.0', 'X 1.25', 'X 1.5',
  ];
  String? selectedValue; // for tts speed - dropdown_button_2



  // dictionary *************************************
  String? _dic_selectedWord; // dictionary word string
  String? _dic_selectedMeaning; // dictionary Meaning string
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

  @override
  void dispose() {
    _stopflag = false;
    _stopSpeakTts();
    super.dispose();
  }

  // init
  _SelectTtsButtonScreenState(this._text, this.currentTTSIndex) {
    print("init _SelectTtsButtonScreenState currentTTSIndex: $currentTTSIndex");

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


  // 문장 옆의 재생 버튼 누르는 경우, 해당 문장만 읽어줌
  void _speakOneSentence (int sentenceIndex, Sentence sentence) async {
    setState(() {
      _updateIsSelected(-1, -1);
    });
    if (!mounted) return;

    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // tts - 읽기 속도
    await _tts.awaitSpeakCompletion(true);

    for (int wordIndex = 0; wordIndex < sentence.words.length; wordIndex++) {
      _updateIsSelected(sentenceIndex, wordIndex);

      // final word = sentence.words[wordIndex].word;
      if (_stopflag) {
        _playflag = true;
        if (_ttsSpeedChangedFlag == true){ // 만약 tts speed 가 변경되었다면
          _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // 변경한 속도로 속도 세팅하고
          _ttsSpeedChangedFlag = false; // _ttsSpeedChangedFlag는 원래대로 false로 초기화
        }
        await _tts.speak(sentence.words[wordIndex].word);
      }
    }

    _playflag = false;
    _updateIsSelected(-1,-1);
  }

  void _speakAllSentence () async {
    setState(() {
      _updateIsSelected(-1, -1);
    });
    if (!mounted) return;

    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // tts - 읽기 속도
    await _tts.awaitSpeakCompletion(true);

    if (currentTTSIndex == 0) { // 현재 저장된 TTS 기록이 없는 경우 처음부터 끝까지 TTS 출력
      for (int sentenceIndex = 0; sentenceIndex < sentenceList.length; sentenceIndex++){
        for (int wordIndex = 0; wordIndex < sentenceList[sentenceIndex].words.length; wordIndex++) {
          _updateIsSelected(sentenceIndex, wordIndex);

          if (_stopflag) {
            _playflag = true;
            if (_ttsSpeedChangedFlag == true){ // 만약 tts speed 가 변경되었다면
              _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // 변경한 속도로 속도 세팅하고
              _ttsSpeedChangedFlag = false; // _ttsSpeedChangedFlag는 원래대로 false로 초기화
            }
            await _tts.speak(sentenceList[sentenceIndex].words[wordIndex].word);
            currentTTSIndex = sentenceList[sentenceIndex].words[wordIndex].wordIndex;

            //마지막까지 출력한 경우 TTS 인덱스 다시 0
            if (sentenceIndex == sentenceList.length - 1 && wordIndex == sentenceList[sentenceIndex].words.length - 1) {
              currentTTSIndex = 0;
            }

          }
        }
      }
    } else { // 현재 저장된 TTS 기록이 있는 경우 기록된 단어부터 끝까지 TTS 출력
      for (int sentenceIndex = 0; sentenceIndex < sentenceList.length; sentenceIndex++) {
        for (int wordIndex = 0; wordIndex < sentenceList[sentenceIndex].words.length; wordIndex++) {
          if (sentenceList[sentenceIndex].words[wordIndex].wordIndex >= currentTTSIndex) {
            _updateIsSelected(sentenceIndex, wordIndex);

            if (_stopflag) {
              _playflag = true;
              if (_ttsSpeedChangedFlag == true){ // 만약 tts speed 가 변경되었다면
                _tts.setSpeechRate(_ttsSpeed[_ttsSpeedIndex]); // 변경한 속도로 속도 세팅하고
                _ttsSpeedChangedFlag = false; // _ttsSpeedChangedFlag는 원래대로 false로 초기화
              }
              await _tts.speak(sentenceList[sentenceIndex].words[wordIndex].word);
              currentTTSIndex = sentenceList[sentenceIndex].words[wordIndex].wordIndex;

              //마지막까지 출력한 경우 TTS 인덱스 다시 0
              if (sentenceIndex == sentenceList.length - 1 && wordIndex == sentenceList[sentenceIndex].words.length - 1) {
                currentTTSIndex = 0;
              }
            }
          }
        }
      }
    }
    print("_speakAllSentence currentTTSIndex: $currentTTSIndex");

    _playflag = false; //전체 재생 버튼 아이콘 제어용
    _updateIsSelected(-1,-1);
  }

  void _speakDictionary(word, meaning) async {
    setState(() {
      _updateIsSelected(-1, -1);
    });

    _tts.setSpeechRate(_ttsSpeed[1]); // tts - 읽기 속도
    await _tts.awaitSpeakCompletion(true);

    await _tts.speak(word);
    await _tts.speak(meaning);

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
    String meaning = dicWords[index].txt_mean;
    String identifier = '$word-$meaning'; // 추가/삭제 위한 식별자 추가
    print("identifier: $identifier");

    DocumentSnapshot snapshot = await wordsRef.doc(identifier).get();
    setState(() {
      _starred[index] = !_starred[index];
    });

    if (_starred[index]) {
      // timestamp
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      wordsRef.doc(identifier).set({
        'word': dicWords[index].txt_emph,
        'meaning': dicWords[index].txt_mean,
        'timestamp': formattedDate, // Add timestamp
      }); // Firestore에 단어가 없을 경우 추가
    } else {
      wordsRef.doc(identifier).delete(); // Firestore에서 단어 삭제
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

  void _dic_showPopup(String word) async {
    final result = await showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Color(0xFF74b29e),
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

                    if (_WebScraperFlag) {
                      return Column(
                        children: [
                          SizedBox(height: 16),
                          Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: dicWords.length,
                                separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10),
                                itemBuilder: (_, index) {
                                  // String word = dicWords[index].txt_emph;
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: wordsRef.doc(word).get(),
                                    builder: (context, snapshot) {
                                      return Padding(
                                        padding: EdgeInsets.fromLTRB(16, 0, 16, 2), // 사전 검색 결과 ListView 사이 간격
                                        child: Container(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _speakDictionary(dicWords[index].txt_emph, dicWords[index].txt_mean);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              onPrimary: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(1),
                                              child: ListTile(
                                                  title: Text(dicWords[index].txt_emph,
                                                      style: const TextStyle(fontSize: 20)),
                                                  subtitle: Text(dicWords[index].txt_mean,
                                                      style: const TextStyle(fontSize: 16)),
                                                  trailing: Container(
                                                    width: 30,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _dic_toggleStarred(index);
                                                        });
                                                      },
                                                      icon: Icon(_starred[index] ? Icons.star : Icons.star_border,
                                                        color: Colors.amber,),),
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                          ),
                          SizedBox(height: 16)
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text("해당하는 단어를 찾을 수 없습니다.", style: TextStyle(fontSize: 18, color: Colors.white)),
                      );
                    }

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
    if (result == null) {
      _dic_toggleSelected("nullnull");
    }

  }


  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;

    return WillPopScope(
        onWillPop: () async {
          _stopflag = false; // TTS 중단
          _stopSpeakTts(); // TTS 중단
          currentTTSIndex = 0; // 페이지 나가면 TTS 이어듣기 인덱스 초기화
          print("WillPopScope currentTTSIndex: $currentTTSIndex");

          return true;
        },
        child: Scaffold(
          backgroundColor: Color(0xffd9ebe5),
          appBar: AppBar(
            backgroundColor: Color(0xffd9ebe5),
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                _stopflag = false;
                _stopSpeakTts();
                Navigator.of(context).pop();
              },
            ),

            actions: [
              IconButton(
                icon: Tooltip(
                  richMessage: WidgetSpan(
                      child: Column(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: const Text("글자 읽기와 사전 검색",
                                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: const Text("버튼을 눌러 재생, 음소거, 속도 조절 기능을 사용해 보세요. 모르는 단어를 누르면 뜻을 확인할 수 있습니다.",
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

        // title: Text(
        //       "I HANGUL",
        //       style: TextStyle(
        //         color: Colors.black,
        //       ),
        //     ),
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

                    // play
                    Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Color(0xFF74b29e),
                        ),
                        child: StatefulBuilder(
                            builder: (context, setState) {
                              return IconButton( // 전체 문장 재생 버튼
                                onPressed: () {
                                  setState(() {
                                    _playflag = !_playflag;
                                    print("setState: $_playflag"); // Check if setState is changing _playflag

                                  });
                                  if (_playflag) {
                                    _stopflag = true;

                                    if (_currentTTSIndexResetFlag == false){ // currentTTSIndex를 reset 할 필요 없을때
                                      if (currentTTSIndex != 0) { // TTS 기록이 존재하는 경우
                                        _speakAllSentence();
                                      }
                                      if (currentTTSIndex == 0){ // TTS 기록이 존재하지 않는 경우
                                        _speakAllSentence();
                                      }
                                    }
                                    if (_currentTTSIndexResetFlag == true){ // currentTTSIndex를 reset 해야할 때
                                      _currentTTSIndexResetFlag = false; // 다시 false로 초기화
                                      currentTTSIndex = 0;
                                      _speakAllSentence();
                                    }

                                  } else {
                                    _stopflag = false; // Stop all TTS
                                    _stopSpeakTts(); // Stop ongoing TTS
                                  }
                                },
                                icon: Icon(Icons.play_arrow, color: Colors.white),
                                // icon: _playflag // 제대로 동작하지 않아서 일단 주석처리
                                //     ? Icon(Icons.stop, color: Colors.black) // TTS 재생 중일 때
                                //     : Icon(Icons.volume_up_outlined, color: Colors.black), // TTS 중단 상태일 때
                              );
                            }
                        )
                    ),

                    Expanded(
                      child: Container(),
                    ),

                    // pause
                    Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Color(0xFF74b29e),
                        ),
                        child: StatefulBuilder(
                            builder: (context, setState) {
                              return IconButton(
                                onPressed: () {
                                  _stopflag = false;
                                  // _stopSpeakTts(); // Stop ongoing TTS
                                },
                                icon: Icon(Icons.pause, color: Colors.white),
                              );
                            }
                        )
                    ),

                    Expanded(
                      child: Container(),
                    ),

                    // stop
                    Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Color(0xFF74b29e),
                        ),
                        child: StatefulBuilder(
                            builder: (context, setState) {
                              return IconButton(
                                onPressed: () {
                                  _stopflag = false;
                                  _currentTTSIndexResetFlag = true; // currentTTSIndex를 reset 해야할 때
                                  // currentTTSIndex = 0; // _speakAllSentence() 함수 때문에 제대로 리셋 안됨
                                  print("currentTTSIndex : $currentTTSIndex");
                                },
                                icon: Icon(Icons.stop, color: Colors.white),
                              );
                            }
                        )
                    ),

                    Expanded(
                      child: Container(),
                    ),

                    // 음소거
                    Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Color(0xFF74b29e),
                        ),
                        child: StatefulBuilder(
                            builder: (context, setState) {
                              return IconButton(
                                onPressed: () {
                                  setState(() {
                                    _muteflag = !_muteflag; // Toggle _muteflag

                                    if (_muteflag) {
                                      _tts.setVolume(1.0);
                                    } else {
                                      _tts.setVolume(0.0);
                                    }
                                  });
                                  },
                                icon: _muteflag
                                    ? Icon(Icons.volume_up, color: Colors.white)
                                    : Icon(Icons.volume_off, color: Colors.white),
                              );
                            }
                        )
                    ),

                    Expanded(
                      child: Container(),
                    ),

                    // TTS speed
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            // Icon(
                            //   Icons.list, color: Colors.white,
                            // ),
                            // SizedBox(
                            //   width: 4,
                            // ),
                            Expanded(
                              child: Text('속도',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: items.map((String item) => DropdownMenuItem<String>(
                          value: item, child: Text(item, style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;

                            print("value: $value");
                            _ttsSpeedChangedFlag = true; // TTS speed가 변경됨
                            switch (value) {
                              case "X 0.5": // TTS 속도 매우 느리게
                                _ttsSpeedIndex = 0;
                                break;
                              case "X 0.75": // TTS 속도 느리게
                                _ttsSpeedIndex = 1;
                                break;
                              case "X 1.0": // TTS 속도 보통
                                _ttsSpeedIndex = 2;
                                break;
                              case "X 1.25": // TTS 속도 빠르게
                                _ttsSpeedIndex = 3;
                                break;
                              case "X 1.5": // TTS 속도 매우 빠르게
                                _ttsSpeedIndex = 4;
                                break;
                              default: // 기본 - TTS 속도 보통
                                _ttsSpeedIndex = 2;
                                break;}
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 40,
                          width: 90,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            // border: Border.all(
                            //   color: Colors.black26,
                            // ),
                            color: Color(0xFF74b29e),
                          ),
                          // elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Colors.white,
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xFF74b29e),
                          ),
                          offset: const Offset(0, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(),
                    ),

                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Color(0xFF74b29e),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _stopSpeakTts();
                          Navigator.pushReplacement(context,
                            MaterialPageRoute(
                              builder: (context) => SelectModifyButtonScreen(text: _text, initialTTSIndex: currentTTSIndex,),
                            ),
                          );
                        },
                        icon: Icon(Icons.border_color_outlined, color: Colors.white),
                      ),
                    ),

                    Expanded(
                      child: Container(),
                    ),

                  ],
                ),

                SizedBox(height: 16.0),

                //original
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: sentenceList.length,
                      padding: EdgeInsets.all(3),
                      itemBuilder: (BuildContext context, int sentenceIndex) {
                        Sentence sentence = sentenceList[sentenceIndex];

                        // List<String> words = sentence.words.map((word) => word.word).toList();

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _playflag = !_playflag;
                                  for (int i = 0; i <
                                      _iconPlayFlags.length; i++) {
                                    _iconPlayFlags[i] = false; // false로 초기화
                                  }
                                });
                                if (_playflag) {
                                  _stopflag = true;
                                  _speakOneSentence(sentenceIndex, sentence); // 한 문장만 읽기
                                } else {
                                  _stopflag = false; // Stop all TTS
                                  _stopSpeakTts(); // Stop ongoing TTS
                                }

                                // if (_playflag && _stopflag){ // 재생 중일 때 아이콘 바꾸기 위한 부분
                                //   _iconPlayFlags[sentenceIndex] = true;
                                // } else {
                                //   _iconPlayFlags[sentenceIndex] = false;
                                // }
                                // print("_stopflag: $_stopflag       _playflag: $_playflag");

                              },
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF74b29e),
                                ),
                                // padding: EdgeInsets.all(8.0),
                                child: _iconPlayFlags[sentenceIndex]
                                    ? Icon(Icons.stop, color: Colors.white)
                                    : Icon(Icons.play_arrow, color: Colors.white),
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
                                              wordIndex: -1,
                                              words: defaultWords,
                                            );
                                          });

                                          return GestureDetector(
                                              onTap: () {
                                                // _dic_showPopup(entry.value.word);
                                                // tts 하이라이트 처리와 사전 하이라이트 처리가 달라야 함
                                                _dic_toggleSelected(entry.value.word);
                                                if (_dic_isSelected(entry.value.word)) {
                                                  _dic_showPopup(entry.value.word);
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(2.0),
                                                decoration: BoxDecoration(
                                                  color: sentenceList[sentenceIndex].words[index].isSelected ? Colors.yellow : (_dic_isSelected(entry.value.word) ? Color(0xffd9ebe5) : null),
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                child: Text(entry.value.word,
                                                  style: TextStyle(fontSize: 18,
                                                    color: sentenceList[sentenceIndex].words[index].isSelected ? Colors.black
                                                        : (_dic_isSelected(entry.value.word) ? Colors.black : null),), // 문장 단위 띄어쓰기 없이 나열
                                                ),)
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
                        return const Divider(
                          color: Color(0xFF74b29e),
                        );
                      },
                    ),
                  )
                ),

                SizedBox(height: 16.0),
              ],
            ),
          ),
        )
    );
  }
}

class WebScraper {
  final String searchWord;
  WebScraper(this.searchWord);

  Future<List<dicWord>> extractData() async {
    final initialUrl =
        "https://dic.daum.net/search.do?q=${Uri.encodeComponent(searchWord)}&dic=kor";
    var responseInitialUrl = await http.get(Uri.parse(initialUrl));
    debugPrint('initialUrl: $initialUrl');

    final RegExp expSupid = RegExp('supid=(.*?)[\'"]');
    final RegExp expWordid = RegExp('wordid=(.*?)[\'"]');

    final matchSupid = expSupid.firstMatch(responseInitialUrl.body);
    final supid = matchSupid?.group(1);
    final matchWordid = expWordid.firstMatch(responseInitialUrl.body);
    final wordid = matchWordid?.group(1);

    final finalUrl =
        'https://dic.daum.net/word/view.do?wordid=$wordid=${Uri.encodeComponent(searchWord)}&supid=$supid';
    debugPrint('finalUrl: $finalUrl');

    var responseFinalUrl = await http.get(Uri.parse(finalUrl));
    final dicWords = <dicWord>[];

    bool _urlflag = false; // 뜻이 여러개/하나인 경우 둘다 크롤링하면 중복된 검색결과 나오는 문제 발생. 둘중 하나만 크롤링하도록 하는 플래그
    _WebScraperFlag = false; // 검색결과가 존재하지 않는 경우 false로 초기화

    if (responseInitialUrl.statusCode == 200) { // 뜻이 여러개인 경우의 URI
      // print("multiful meaning");
      final html = parser.parse(responseInitialUrl.body);

      // 뜻이 여러개인 경우
      final container1 = html.querySelectorAll('.search_box'); // 뜻 여러개 - 맨 위 검색결과
      final container2 = html.querySelectorAll('div.card_word[data-target="word"][data-tiara-layer="word word"] .search_type'); // 뜻 여러개 - 아래쪽 검색 결과
      // final container3 = html.querySelectorAll('.inner_top'); // 뜻 하나

      // timeStamp
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      if (container1.isNotEmpty || container2.isNotEmpty) { // 뜻이 여러개인 경우
        for (final element in container1) {
          final txt_emph = element.querySelector('.txt_cleansch')?.text?.trim().replaceAll(RegExp(r'[0-9]'), '');
          final txt_mean = element.querySelector('.txt_search')?.text?.trim();
          // print("container1: $txt_emph -  $txt_mean");

          if (txt_emph != null && txt_mean != null) {
            _urlflag = true; // 크롤링하면 _urlflag를 true로 바꿈
            _WebScraperFlag = true; // 검색결과가 존재하는 경우 true
            dicWords.add(dicWord(txt_emph: txt_emph, txt_mean: txt_mean, timestamp: formattedDate));
          }
        }

        for (final element in container2) {
          final txt_emph = element.querySelector('.txt_searchword')?.text?.trim().replaceAll(RegExp(r'[0-9]'), '');
          final txt_mean = element.querySelector('.txt_search')?.text?.trim();
          // print("container2: $txt_emph -  $txt_mean");

          if (txt_emph != null && txt_mean != null) {
            _urlflag = true; // 크롤링하면 _urlflag를 true로 바꿈
            _WebScraperFlag = true; // 검색결과가 존재하는 경우 true
            dicWords.add(dicWord(txt_emph: txt_emph, txt_mean: txt_mean, timestamp: formattedDate));
          }
        }
      }
    }
    if (responseFinalUrl.statusCode == 200 && _urlflag == false ) { // _urlflag가 false(크롤링X)인 경우에만 if문 실행
      // print("one meaning");
      final html = parser.parse(responseFinalUrl.body);

      // 뜻이 하나인 경우
      final container3 = html.querySelectorAll('.inner_top'); // 뜻 하나

      // timeStamp
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      if (container3.isNotEmpty) {  // 뜻이 한개인 경우
        // print("container3.isNotEmpty");
        for (final element in container3) {
          final txt_emph = element.querySelector('.txt_cleanword')?.text?.trim();
          final txt_meanElements = element.querySelectorAll('.txt_mean'); // 'txt_mean' 여러 개일 때
          final txt_means = txt_meanElements.map((element) => element.text.trim()).toList();

          if (txt_emph != null && txt_means.isNotEmpty) {
            for (final txt_mean in txt_means) {
              _WebScraperFlag = true; // 검색결과가 존재하는 경우 true
              dicWords.add(dicWord(txt_emph: txt_emph, txt_mean: txt_mean, timestamp: formattedDate));
            }
          }
        }
      }
    } else {
      // _WebScraperFlag = false; // 검색결과가 존재하지 않는 경우 false
      // print("_WebScraperFlag: $_WebScraperFlag");
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
