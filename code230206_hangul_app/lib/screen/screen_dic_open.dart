// *** 사전 open 스크린 ***
// screen_dic.dart에서 클릭한 단어에 대한 다음 사전 검색 결과를 보여주는 스크린

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'screen_dic_open.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
//Web scraping 참고: https://github.com/muath-gh/flutter_web_scraping

class DicOpenScreen extends StatefulWidget {
  static const String DicOpenScreenRouteName = "/DicOpenScreen";
  final String DicOpenScreenText;
  DicOpenScreen({required this.DicOpenScreenText});

  @override
  _DicOpenScreen createState() => _DicOpenScreen();
}

class _DicOpenScreen extends State<DicOpenScreen> {
  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    final args = ModalRoute.of(context)!.settings.arguments as DicOpenScreen;
    final WebScraper webScraper =  WebScraper(args.DicOpenScreenText);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            toolbarHeight: width*0.15,
            title: Text("I HANGUL"),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                  gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent,Colors.deepPurple],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter
                  )
              ),
            ),
          ),
          body: FutureBuilder(
            future: webScraper.extractData(),
            builder: (_, snapShot) {
              if (snapShot.hasData) {
                List<dicWord> dicWords = snapShot.data as List<dicWord>;
                return Column(
                  children: [
                    Text(
                      '${args.DicOpenScreenText}',
                      style: TextStyle(
                        fontSize: width * 0.050,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: dicWords.length,
                      itemBuilder: (_, index) {
                        return Padding( // word list 출력
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10),

                              child: Text(
                                dicWords[index].txt_emph,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            subtitle: Text(dicWords[index].txt_mean,
                              style: const TextStyle(fontSize: 15),
                            ),

                          ),
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
          )
        )
    );
  }
}

// 다음 사전 Web scraping 클래스
// 수정 필요
class WebScraper {
  String searchWord = '';

  WebScraper(String searchWord)
      : this.searchWord = searchWord;

  Future<List<dicWord>> extractData() async {
    // String url = "https://dic.daum.net/search.do?q=" + Uri.encodeComponent(searchWord); //1개용
    String url = "https://dic.daum.net/search.do?q=" + Uri.encodeComponent(searchWord);

    // String url = "https://ko.dict.naver.com/#/search?query=" + Uri.encodeComponent(searchWord);
    http.Response response = await http.get(Uri.parse(url));
    List<dicWord> dicWords = [];
    if (response.statusCode == 200) {
      final html = parser.parse(response.body);
      // container: item-cells-wrap //전체 감싼거
      // div: item-container // 상품 하나

      // final container = html.querySelector(".component_keyword has-saving-function")!.children; //전체 감싼거 //네이버
      final container = html.querySelector(".card_word")!.children; //전체 감싼거 //다음
      // final container = html.querySelector(".inner_toop")!.children; //전체 감싼거 //다음 // 1개용

      container.forEach((element) {
        try {
          //검색시 맨 위에 있는 메인 단어 보여줌 - 70%커버
          // String txt_emph = element.getElementsByClassName("search_cleanword")[0].querySelector(".tit_cleansch .txt_emph1")!.text; // 다음
          // String txt_mean = element.getElementsByClassName("list_search")[0].querySelector(".txt_search")!.text; // 다음

          //검색시 단어 리스트들 보여줌(메인X) 메인 단어가 있을 경우 뜻이 밀리는 문제 발생
          String txt_emph = element.getElementsByClassName("search_word")[0].querySelector(".tit_searchword .txt_searchword")!.text; // 다음
          String txt_mean = element.getElementsByClassName("list_search")[0].querySelector(".txt_search")!.text; // 다음

          dicWords.add(dicWord(txt_emph:txt_emph, txt_mean: txt_mean));

        } catch (e) {
          print(e);
        }
      });
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