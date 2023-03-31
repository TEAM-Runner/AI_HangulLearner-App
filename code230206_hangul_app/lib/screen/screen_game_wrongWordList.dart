
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';


class GameWrongWordListScreen extends StatefulWidget {
  static const String GameWrongWordListScreenRouteName = "/GameWrongWordListScreen";
  final List<Tuple3<String, String, bool>> GameWrongWordListScreenText;
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
    final List<Tuple3<String, String, bool>> words = List.from((args.GameWrongWordListScreenText));

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
            body: Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  return Card(

                    // ***** ver 1: 옆에 O/X 아이콘 표시
                    child: ListTile(
                      title: Text(words[index].item1, style: const TextStyle(fontSize: 20)),
                      subtitle: Text(words[index].item2, style: const TextStyle(fontSize: 20)),
                      trailing: Icon(
                        words[index].item3 ? Icons.circle_outlined : Icons.close,
                        color: words[index].item3 ? Colors.blue: Colors.red,
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
