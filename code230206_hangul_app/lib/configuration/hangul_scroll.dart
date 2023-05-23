/// Modified alphabet_scroll_view 0.3.2 to Korean version
/// https://pub.dev/packages/alphabet_scroll_view

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

enum LetterAlignment { left, right }

// const List<String> alphabets = [
//   'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
// ];

const List<String> alphabets = [
  "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ",
  "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
  "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ",
  "ㅋ", "ㅌ", "ㅍ", "ㅎ"
];

class AlphabetScrollView extends StatefulWidget {

  AlphabetScrollView(
      {Key? key,
        required this.list,
        this.alignment = LetterAlignment.right,
        this.isAlphabetsFiltered = true,
        this.overlayWidget,
        required this.selectedTextStyle,
        required this.unselectedTextStyle,
        this.itemExtent = 40,
        required this.itemBuilder,
        required this.screenHeight, // add to calculate scroll position
      })
      : super(key: key);

  final List<AlphaModel> list;
  final double itemExtent;
  final LetterAlignment alignment;
  final bool isAlphabetsFiltered;
  final Widget Function(String)? overlayWidget;
  final TextStyle selectedTextStyle;
  final TextStyle unselectedTextStyle;
  final double screenHeight; // add to calculate scroll position



  Widget Function(BuildContext, int, String) itemBuilder;

  @override
  _AlphabetScrollViewState createState() => _AlphabetScrollViewState();
}

class _AlphabetScrollViewState extends State<AlphabetScrollView> {

  void init() {
    widget.list.sort((x, y) => x.key.toLowerCase().compareTo(y.key.toLowerCase())); // 리스트 정렬. 대문자인 경우 소문자로 변환해 비교
    _list = widget.list;
    setState(() {});

    /// filter Out AlphabetList
    if (widget.isAlphabetsFiltered) {
      List<String> temp = [];
      alphabets.forEach((letter) {
        AlphaModel? firstAlphabetElement;
        try {
          firstAlphabetElement = _list.firstWhere(
                (item) {
              final itemKoreanCharacter = getKoreanCharacter(item.key);
              return itemKoreanCharacter == letter;

            },
          );
        } catch (e) {
          firstAlphabetElement = null;
        }
        if (firstAlphabetElement != null) {
          temp.add(letter);
        }
      });
      _filteredAlphabets = temp;
    } else {
      _filteredAlphabets = alphabets;
    }
    calculateFirstIndex();
    setState(() {});
  }

  @override
  void initState() {
    init();
    if (listController.hasClients) {
      maxScroll = listController.position.maxScrollExtent;
    }
    super.initState();
  }


  ScrollController listController = ScrollController();
  final _selectedIndexNotifier = ValueNotifier<int>(0);
  final positionNotifer = ValueNotifier<Offset>(Offset(0, 0));
  final Map<String, int> firstIndexPosition = {};
  List<String> _filteredAlphabets = [];
  final letterKey = GlobalKey();
  List<AlphaModel> _list = [];
  bool isLoading = false;
  bool isFocused = false;
  final key = GlobalKey();

  @override
  void didUpdateWidget(covariant AlphabetScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list ||
        oldWidget.isAlphabetsFiltered != widget.isAlphabetsFiltered) {
      _list.clear();
      firstIndexPosition.clear();
      init();
    }
  }

  int getCurrentIndex(double vPosition) {
    double kAlphabetHeight = letterKey.currentContext!.size!.height;
    return (vPosition ~/ kAlphabetHeight);
  }

  void calculateFirstIndex() {

    _filteredAlphabets.forEach((letter) {
      AlphaModel? firstElement = _list.firstWhereOrNull((item) {
        final koreanCharacter = getKoreanCharacter(item.key);
        return koreanCharacter == letter;
      });

      if (firstElement != null) {
        int index = _list.indexOf(firstElement);
        final koreanCharacter = getKoreanCharacter(firstElement.key);
        firstIndexPosition[letter] = index;
      }
    });
  }

  // original
  // void calculateFirstIndex() {
  //   _filteredAlphabets.forEach((letter) {
  //     AlphaModel? firstElement = _list.firstWhereOrNull(
  //             (item) => item.key.toLowerCase().startsWith(letter));
  //     if (firstElement != null) {
  //       int index = _list.indexOf(firstElement);
  //       firstIndexPosition[letter] = index;
  //     }
  //   });
  // }

  String? getKoreanCharacter(String word) {

    final koreanCharacter = word.characters.first;
    final unicodeValue = koreanCharacter.codeUnitAt(0);
    List<String> initialConsonants = [
      "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ",
      "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
      "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ",
      "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ];

    if (unicodeValue >= 0xAC00 && unicodeValue <= 0xD7A3) {
      final consonantIndex = ((unicodeValue - 0xAC00) ~/ (21 * 28));
      // final consonantUnicode = 0x1100 + consonantIndex;

      return initialConsonants[consonantIndex];
    }

    // return 'something wrong';

  }

  int getKoreanCharacter2(String character) {
    final int base = 44032;
    final int consonantCount = 28;
    final int vowelCount = 21;
    final int finalConsonantCount = 28;

    int code = character.codeUnitAt(0);

    if (code >= 12593 && code <= 12622) {
      int index = code - base;
      int consonantIndex = index ~/ (vowelCount * finalConsonantCount);

      return consonantIndex + 1;
    } else {
      return -1;
    }
  }




  // final GlobalKey _listKey = GlobalKey();
  void scrolltoIndex(int x, Offset offset) {
    print("scrolltoIndex offset: $offset");
    int index = firstIndexPosition[_filteredAlphabets[x].toLowerCase()]!;
    final int itemCount = (widget.screenHeight / widget.itemExtent).ceil();
    final scrollToPosition  = widget.itemExtent * index;

    // final cardPosition = offset.dy;
    // final cardHeight = (context.findRenderObject() as RenderBox).size.height;
    // final scrollToPosition  = widget.itemExtent * index - cardPosition + cardHeight / 2;

    // print("scrolltoIndex cardPosition: $cardPosition");
    // print("scrolltoIndex cardHeight: $cardHeight");
    // print("scrolltoIndex scrollToPosition: $scrollToPosition");

    if (index != null) {
      listController.animateTo((scrollToPosition ),
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    positionNotifer.value = offset;
  }

  void onVerticalDrag(Offset offset) {
    int index = getCurrentIndex(offset.dy);
    if (index < 0 || index >= _filteredAlphabets.length) return;
    _selectedIndexNotifier.value = index;
    setState(() {
      isFocused = true;
    });
    scrolltoIndex(index, offset);
  }

  double? maxScroll;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
            controller: listController,
            scrollDirection: Axis.vertical,
            itemCount: _list.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (_, x) {
              return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.itemExtent),
                  child: widget.itemBuilder(_, x, _list[x].key));
            }),
        Align(
          alignment: widget.alignment == LetterAlignment.left
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Container(
            key: key,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SingleChildScrollView(
              child: GestureDetector(
                onVerticalDragStart: (z) => onVerticalDrag(z.localPosition),
                onVerticalDragUpdate: (z) => onVerticalDrag(z.localPosition),
                onVerticalDragEnd: (z) {
                  setState(() {
                    isFocused = false;
                  });
                },
                child: ValueListenableBuilder<int>(
                    valueListenable: _selectedIndexNotifier,
                    builder: (context, int selected, Widget? child) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _filteredAlphabets.length,
                                (x) => GestureDetector(
                              key: x == selected ? letterKey : null,
                              onTap: () {
                                _selectedIndexNotifier.value = x;
                                scrolltoIndex(x, positionNotifer.value);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                child: Text(
                                  _filteredAlphabets[x].toUpperCase(),
                                  style: selected == x
                                      ? widget.selectedTextStyle
                                      : widget.unselectedTextStyle,
                                ),
                              ),
                            ),
                          ));
                    }),
              ),
            ),
          ),
        ),
        !isFocused
            ? Container()
            : ValueListenableBuilder<Offset>(
            valueListenable: positionNotifer,
            builder:
                (BuildContext context, Offset position, Widget? child) {
              return Positioned(
                  right:
                  widget.alignment == LetterAlignment.right ? 40 : null,
                  left:
                  widget.alignment == LetterAlignment.left ? 40 : null,
                  top: position.dy,
                  child: widget.overlayWidget == null
                      ? Container()
                      : widget.overlayWidget!(_filteredAlphabets[
                  _selectedIndexNotifier.value]));
            })
      ],
    );
  }
}

class AlphaModel {
  final String key;
  final String? secondaryKey;

  AlphaModel(this.key, {this.secondaryKey});
}
