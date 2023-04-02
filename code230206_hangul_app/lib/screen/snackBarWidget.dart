import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;


class SnackBarWidget{
  static final messengerKey = GlobalKey<ScaffoldMessengerState>(); //원래 이 위치

  static showSnackBar(String? text){
    if (text == null) return;

    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red,);
    // final messengerKey = GlobalKey<ScaffoldMessengerState>();

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}