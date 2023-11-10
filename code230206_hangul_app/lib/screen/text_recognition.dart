import 'dart:io';
import 'package:code230206_hangul_app/screen/screen_select_TtsButton.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:code230206_hangul_app/screen/screen_select_dicButton.dart';

class ScanImageProcessor {
  final BuildContext context;
  final Function(String) onScanSuccess;
  final Function(String) onScanError;

  ScanImageProcessor({
    required this.context,
    required this.onScanSuccess,
    required this.onScanError,
  });

  Future<void> processImage(File imageFile, TextRecognizer textRecognizer) async {
    final String testtext =
        '아이린은 양털 장화를 신고. 빨간 모자와 목도리를 두르고. 두꺼운 외투를 입고, 벙어리장갑을 꼈습니다. 그런 다음 엄마의 뜨거운 이마에 여섯 번이나 입을 맞추고, 한번 더 맞추었습니다. 아이린은 엄마의 이불이 잘 덮였나 확인하고 나서 커다란 옷 상자를 들고 살며시 밖으로 나왔습니다. 그리고 문을 꼭 닫았습니다.';
    final navigator = Navigator.of(context);

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);

      onScanSuccess(recognizedText.text);

          await navigator.pushReplacement(
            // 기본 코드
              MaterialPageRoute(builder: (context) => SelectTtsButtonScreen(text: recognizedText.text, initialTTSIndex: 0))

            // 1차 테스트용 코드: screen_Camera_result.dart로 연결
            // MaterialPageRoute(builder: (context) => ResultScreen(text: testtext))

            // 2차 테스트용 코드: 지도교수님과 면담 후 인터페이스 수정용
            // MaterialPageRoute(builder: (context) => SelectDicButtonScreen(text: recognizedText.text),),
          );
        } catch (e) {
          onScanError(e.toString());

          // 테스트용 코드
          // await navigator.pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) => SelectDicButtonScreen(text: testtext),
          //   ),
          // );

          // 기본 코드
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred when scanning text')));
        }

    }
  }
