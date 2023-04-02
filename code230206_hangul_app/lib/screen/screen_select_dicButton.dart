import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
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
          // final args = ModalRoute.of(context)!.settings.arguments as SelectDicScreen;
          final WebScraper webScraper = WebScraper('$word');

          return Container(
            height: 300.0,
            child: FutureBuilder(
              future: webScraper.extractData(),
              builder: (BuildContext context, AsyncSnapshot<List<dicWord>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      final dicWord = snapshot.data![index];
                      return ListTile(
                        title: Text(dicWord.txt_emph),
                        subtitle: Text(dicWord.txt_mean),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
        }
      // builder: (context) => Container(
      //   height: 100.0,
      //   child: Column(
      //     children: [
      //       Center(
      //         child: Text('$word'),
      //       ),
      //     ],
      //   )
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> words = _selectedWords.map((word) => _buildWord(word)).toList();

    // final args = ModalRoute.of(context)!.settings.arguments as SelectDicScreen;
    // final WebScraper webScraper = WebScraper(args.text);

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


