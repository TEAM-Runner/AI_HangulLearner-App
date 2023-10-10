import 'package:dcdg/dcdg.dart';
import 'package:code230206_hangul_app/screen/screen_splash.dart';
import 'package:code230206_hangul_app/screen/snackBarWidget.dart';
import 'package:flutter/material.dart';
import 'configuration/my_style.dart';
import 'screen/screen_dic.dart';
import 'screen/screen_dic_open.dart';
import 'screen/screen_tts.dart';
import 'screen/screen_auth_Login.dart';
import 'screen/screen_game_result.dart';
import 'screen/screen_game_wrongWordList.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String DicScreenText = '';
  String TTSScreenText = '';
  String DicOpenScreenText= '';
  List<List<dynamic>>  GameResultScreenText = [];
  List<List<dynamic>>  GameWrongWordListScreenText = [];


  runApp(MaterialApp(
    scaffoldMessengerKey: SnackBarWidget.messengerKey,
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,

    // login, sign up 화면 prefix icon color 위해 추가
    //rgb(169, 227, 75)       #a9e34b
    theme: ThemeData().copyWith(
      colorScheme: ThemeData().colorScheme.copyWith(
        primary: Color(0xa9e34b),
      ),
    ),
    title: 'GP App',
    initialRoute: 'splash',
    routes: {
      '/':(context) => LoginScreen(),
      'splash':(context) => const SpalshScreen(),

      // '/DicScreen':(context) => DicScreen(DicScreenText: DicScreenText),
      // '/TTSScreen':(context) => TTSScreen(TTSScreenText: TTSScreenText),
      // '/DicOpenScreen':(context) => DicOpenScreen(DicOpenScreenText: DicOpenScreenText),
      '/GameResultScreen':(context) => GameResultScreen(GameResultScreenText: GameResultScreenText),
      '/GameWrongWordListScreen':(context) => GameWrongWordListScreen(GameWrongWordListScreenText: GameWrongWordListScreenText),

    },
  ));
}
