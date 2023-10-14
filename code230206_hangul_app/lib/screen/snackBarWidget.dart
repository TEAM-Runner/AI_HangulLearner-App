import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;


class SnackBarWidget{
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text){
    if (text == null) return;

    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red,);

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}