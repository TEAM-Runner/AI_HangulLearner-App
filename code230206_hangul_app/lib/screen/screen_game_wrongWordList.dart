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
                              child: const Text("단어 다시보기",
                                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: const Text("퀴즈에 나온 단어를 다시 볼 수 있어요. 맞힌 단어는 O로, 틀린 단어는 X로 표시돼요.",
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
            body: Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  return Card(
                      shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20.0),),
                    // ***** ver 1: 옆에 O/X 아이콘 표시
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Padding(
                        padding:EdgeInsets.only(bottom: 8.0),
                        child: Text(words[index][0], style: const TextStyle(fontSize: 20)),
                      ),
                      subtitle: Text(words[index][1], style: const TextStyle(fontSize: 16)),
                      trailing: Icon(
                        words[index][2] ? Icons.circle_outlined : Icons.close,
                        color: words[index][2] ? Color(0xFF74b29e): Color(0xFF74b29e)
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
