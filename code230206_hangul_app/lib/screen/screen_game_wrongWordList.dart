
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';


class GameWrongWordListScreen extends StatefulWidget {
  static const String GameWrongWordListScreenRouteName = "/GameWrongWordListScreen";
  final List<List<dynamic>> GameWrongWordListScreenText;
  GameWrongWordListScreen({required this.GameWrongWordListScreenText});

  @override
  _GameWrongWordListScreenState createState() => _GameWrongWordListScreenState();

}

class _GameWrongWordListScreenState extends State<GameWrongWordListScreen>{

  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    final args = ModalRoute.of(context)!.settings.arguments as GameWrongWordListScreen;
    final List<List<dynamic>> words = List.from((args.GameWrongWordListScreenText));

    return SafeArea(
        child: Scaffold(
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
              child: ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  return Card(

                    // ***** ver 1: 옆에 O/X 아이콘 표시
                    child: ListTile(
                      title: Text(words[index][0], style: const TextStyle(fontSize: 20)),
                      subtitle: Text(words[index][1], style: const TextStyle(fontSize: 20)),
                      trailing: Icon(
                        words[index][2] ? Icons.circle_outlined : Icons.close,
                        color: words[index][2] ? Colors.blue: Colors.red,
                      ),
                    ),

                    // ***** ver 2: 글자색 변경
                    // child: ListTile(
                    //     title: Text(words[index].item1, style: TextStyle(
                    //         fontSize: 20,
                    //         color: words[index].item3 ? Colors.blue: Colors.red)),
                    //     subtitle: Text(words[index].item2, style: TextStyle(
                    //         fontSize: 20,
                    //         color: words[index].item3 ? Colors.blue: Colors.red)
                    //     ),
                    //   ),
                  );
                },
              ),
            )
        )
    );
  }
}
