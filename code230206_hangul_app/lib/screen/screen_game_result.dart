import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'screen_game_wrongWordList.dart';


class GameResultScreen extends StatefulWidget {
  static const String GameResultScreenRouteName = "/GameResultScreen";
  // GameResultScreen({required this.words, required String GameResultScreenText});
  final List<Tuple3<String, String, bool>> GameResultScreenText;
  GameResultScreen({required this.GameResultScreenText});

  @override
  _GameResultScreenState createState() => _GameResultScreenState();
}


class _GameResultScreenState extends State<GameResultScreen>{


  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    final args = ModalRoute.of(context)!.settings.arguments as GameResultScreen;
    final List<Tuple3<String, String, bool>> words = List.from((args.GameResultScreenText));

    int correctCount = 0;
    for (var word in words) {
      if (word.item3 == true) { correctCount++; }
    }

    String message;
    if (correctCount == 10) {
      message = '최고에요!';
    } else if (correctCount >= 7) {
      message = '훌륭해요!';
    } else if (correctCount >= 5) {
      message = '잘했어요!';
    } else {
      message = '조금만 더 노력해 봐요!';
    }

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            toolbarHeight: width * 0.15,
            title: const Text('Starred Words'),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.deepPurple],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$correctCount/${words.length}',
                  style: TextStyle(fontSize: 48),
                ),
                SizedBox(height: 16),
                Text( message, style: TextStyle(fontSize: 24),),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, GameWrongWordListScreen.GameWrongWordListScreenRouteName, arguments: GameWrongWordListScreen(GameWrongWordListScreenText: words));
                  },
                  child: Text('단어 다시보기'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 랭킹 화면으로 연결
                  },
                  child: Text('기록 확인하기'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {Navigator.pop(context);},
                  child: Text('게임 나가기'),
                ),
              ],
            ),
          ),
        )
    );
  }
}


