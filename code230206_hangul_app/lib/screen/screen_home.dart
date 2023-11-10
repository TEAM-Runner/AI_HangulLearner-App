import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screen_Camera.dart';
import 'dart:ui';
import 'screen_profile.dart';
import 'screen_vacabularyList.dart';
import 'screen_game.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'text_recognition.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final textRecogizer = TextRecognizer(script: TextRecognitionScript.korean);

  final ImagePicker picker = ImagePicker();
  // final ScanImageProcessor scanImageProcessor = ScanImageProcessor();

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    textRecogizer.close(); // 글자인식 관련
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
          backgroundColor: Color(0xffd9ebe5),
          appBar: AppBar(
            backgroundColor: Color(0xffd9ebe5),
            elevation: 0.0,
            // toolbarHeight: width*0.15,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: ()=> exit(0),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),
            ],
            //title: Text("I HANGUL",style: TextStyle(color: Colors.black,),),
            //centerTitle: true,
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  height: height*1.0,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      makeButton('책 읽기', 1 , '궁금한 부분을 찰칵!', 1),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),

                      makeButton('단어장', 3 , '내가 찾은 단어 보러 가기!', 3),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),

                      makeButton('게임', 2 , '초성 게임으로 실력 향상!', 2),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),

                      // Text("추천단어", style: TextStyle(fontSize: width * 0.045),),
                      // //TODO: Recommended Words for Review
                      // Placeholder(),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

  // 카메라, 학습게임, 단어장 버튼을 만드는 위젯
  Widget makeButton(String title, int iconNumber, String buttonText, int onPressNumber){
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;


    return Container(
      width: width*0.4,
      child: ElevatedButton(
        onPressed: ()  async {
          if (onPressNumber == 1){ //카메라 버튼 클릭
            final picker = ImagePicker();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),),
                  title: Text("사진을 가져올 방법을 선택하세요",
                    style: TextStyle(color: Colors.white, fontSize: 19)),
                  backgroundColor: Color(0xFF74b29e),
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.fromSize( // 카메라 선택
                        size: Size(80, 80),
                        child: Material(
                          color: Colors.white, // button color
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              WidgetsFlutterBinding.ensureInitialized();
                              final cameras = await availableCameras();
                              final firstCamera = cameras.first;
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.camera_alt_outlined, size: 38), // icon
                                ),
                                Text("카메라"), // text
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 40.0),

                      SizedBox.fromSize( // 갤러리 선택
                        size: Size(80, 80),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: InkWell(
                            // splashColor: Colors.green, // splash color
                            onTap: () async {
                              print("### log ### : onTap");
                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                final file = File(pickedFile.path);
                                final scanImageProcessor = ScanImageProcessor(
                                  context: context,
                                  onScanSuccess: (text) {
                                    print("Scanned Text: $text");
                                  },
                                  onScanError: (error) {
                                    print("Error: $error");
                                  },
                                );
                                scanImageProcessor.processImage(file, textRecogizer);
                              } else {
                                print("### log ### : else");
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.photo_library, size: 38), // icon
                                ),
                                Text("갤러리"), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          if (onPressNumber == 2){ //학습게임 버튼 클릭
            // screen_game.dart로 연결
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameScreen()));
          }
          if (onPressNumber == 3){//단어장 버튼 클릭
            Navigator.push(context, MaterialPageRoute(builder: (context) => VocabularyListScreen()));
          }
        },
        style: ButtonStyle(
          elevation:MaterialStateProperty.all<double>(0),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          backgroundColor:MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                //side: BorderSide(color: Color(0xFFa8df83), width: 2.0)
              )
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                SizedBox(height: 40.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: width * 0.1, maxHeight: height * 0.05),
                  child: Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      Positioned(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            customButton: const Icon(
                              Icons.help_outline,
                              size: 25,
                              color: Colors.black,
                            ),
                            items: onPressNumber == 1
                                ? MenuItems.cameraItems.map(
                                  (item) => DropdownMenuItem<MenuItem>(
                                value: item,
                                child: MenuItems.buildItem(item),
                              ),
                            ).toList()
                                : onPressNumber == 2
                                ? MenuItems.gameItems.map(
                                  (item) => DropdownMenuItem<MenuItem>(
                                value: item,
                                child: MenuItems.buildItem(item),
                              ),
                            ).toList()
                                : MenuItems.vocabularyItems.map(
                                  (item) => DropdownMenuItem<MenuItem>(
                                value: item,
                                child: MenuItems.buildItem(item),
                              ),
                            ).toList(),
                            onChanged: (value) {
                              // MenuItems.onChanged(context, value! as MenuItem);
                            },
                            dropdownStyleData: DropdownStyleData(
                              width: 270,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF74b29e), // Border color
                                  width: 1.0, // Border width
                                ),
                                color: Colors.white,
                              ),
                              offset: const Offset(-245, -5),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 70, // 팝업창 높이 - 메시지 수정 시 조절 필요
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                // Text(title, style: TextStyle(fontSize: width * 0.045),),
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.only(top: width * 0.03)),
                // <-- Text
                // SizedBox(width: width*0.3,),
                Icon(
                  // <-- Icon
                  _choiceIcon(iconNumber),
                  size: width * 0.1,
                ),
                Padding(padding: EdgeInsets.only(top: width * 0.04)),
                // Text(buttonText, style: TextStyle(fontSize: width * 0.036),),
                Text(
                  buttonText,
                  style: TextStyle(fontSize: 20),
                ),
                Padding(padding: EdgeInsets.only(top: width * 0.12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 카메라, 학습게임, 단어장 버튼의 아이콘을 -리턴하는 함수
  _choiceIcon(int num) {
    switch(num) {
      case 1:
        return Icons.camera_alt_outlined;
      case 2:
        return Icons.videogame_asset_outlined;
      case 3:
        return Icons.book_outlined;
    }
  }
}

class MenuItem {
  const MenuItem({
    required this.text_title,
    required this.text_detail,
  });

  final String text_title;
  final String text_detail;
}

abstract class MenuItems {
  static const List<MenuItem> cameraItems = [camera];
  static const List<MenuItem> vocabularyItems = [vocabulary];
  static const List<MenuItem> gameItems = [game];

  // 메시지 수정 시 MenuItemStyleData -> height 조절 필요
  static const camera = MenuItem(
      text_title: '책 읽기',
      text_detail: '책을 읽기 어렵다면 촬영해 보세요. 문장을 듣고 단어를 검색해요.'
  );
  static const vocabulary = MenuItem(
      text_title: '단어장',
      text_detail: '학습한 단어를 기억하고 있나요? 저장한 단어를 복습할 수 있어요.'
  );
  static const game = MenuItem(
      text_title: '초성 게임',
      text_detail: '단어장에 저장한 단어로 초성 게임을 할 수 있어요.'
  );

  static Widget buildItem(MenuItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            item.text_title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          item.text_detail,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 15
          ),
        ),
      ],
    );
  }

}