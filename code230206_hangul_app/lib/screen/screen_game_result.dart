import 'package:code230206_hangul_app/configuration/my_style.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'screen_game_wrongWordList.dart';
import 'screen_game.dart';

class GameResultScreen extends StatefulWidget {
  static const String GameResultScreenRouteName = "/GameResultScreen";
  // GameResultScreen({required this.words, required String GameResultScreenText});
  final List<List<dynamic>> GameResultScreenText;
  GameResultScreen({required this.GameResultScreenText});

  @override
  _GameResultScreenState createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    final args = ModalRoute.of(context)!.settings.arguments as GameResultScreen;
    final List<List<dynamic>> words = List.from((args.GameResultScreenText));

    int correctCount = 0;
    for (var word in words) {
      if (word[2] == true) {
        correctCount++;
      }
    }

    // 5문제 기준
    String first_message;
    String second_message;

    if (correctCount == 5) {
      first_message = '최고에요!';
      second_message = '퀴즈를 모두 맞혔어요';
    } else if (correctCount == 4) {
      first_message = '훌륭해요!';
      second_message = '하나만 더 맞혀 봐요!';
    } else if (correctCount == 3) {
      first_message = '잘했어요!';
      second_message = '계속 공부해 봐요!';
    }else if (correctCount == 2) {
      first_message = '아쉬워요';
      second_message = '계속 공부해 봐요!';
    } else if (correctCount == 1) {
      first_message = '아쉬워요';
      second_message = '더 잘할 수 있어요!';
    }  else {
      first_message = '아쉬워요';
      second_message = '조금만 더 노력해 봐요!';
    }

    return SafeArea(
        child: Scaffold(
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
                            child: const Text("점수 확인하기",
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: const Text("내가 맞힌 퀴즈 개수를 확인해요. 퀴즈 단어를 다시 보거나, 퀴즈를 다시 풀 수 있어요.",
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

            // title:Image.asset("assets/images/i_hangul.png"),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
                Text(
                  '$correctCount/${words.length}',
                  style: const TextStyle(fontSize: 100, color:Color(0xFF74b29e), fontWeight:FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  first_message,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight:FontWeight.bold,
                    // color:Color(0xFF74b29e),
                  ),
                ),
                Text(
                  second_message,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:FontWeight.bold,
                    // color:Color(0xFF74b29e),
                  ),
                ),
                SizedBox(height: 64),
                SizedBox(
                  width: width * 0.5,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:MaterialStateProperty.all<Color>(Color(0xFF74B29E),),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      ),
                    onPressed: () {
                      Navigator.pushNamed(context,
                          GameWrongWordListScreen.GameWrongWordListScreenRouteName,
                          arguments: GameWrongWordListScreen(
                              GameWrongWordListScreenText: words));
                    },
                    child: Text(
                      '단어 다시보기',
                      style: TextStyle(fontSize: width * 0.045, color: Colors.white),
                    ),
                  ),
                ),



                SizedBox(height: 16),
                SizedBox(
                  width: width * 0.5, // <-- Your width
                  height: 50, // <-- Your height
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:MaterialStateProperty.all<Color>(Color(0xFF74B29E),),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GameScreen()));
                    },
                    child: Text(
                      '다시풀기',
                      style: TextStyle(fontSize: width * 0.045, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: width * 0.5, // <-- Your width
                  height: 50, // <-- Your height
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:MaterialStateProperty.all<Color>(Color(0xFF74B29E),),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '게임 나가기',
                      style: TextStyle(fontSize: width * 0.045, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
    ));
  }
}
