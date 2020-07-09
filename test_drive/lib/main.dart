import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appName = 'Startup Name Generator';

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: appName,
      home: Builder(
        builder: (context) => wrapWithBrightnessAwareTheme(
          context: context,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(appName),
            ),
            // FIXME: This works fine with light mode, but in dark mode, the text stays dark! And the dividers go black?
            // The navbar text displays fine in both modes, though.
            //
            // With the addition of the wrapping Theme, the navbar stays in light mode at all times, while the main content only sort of goes into dark mode.

            // FIXME: This is underlapping the navbar.
            child: Center(
              child: RandomWords(),
            ),
          ),
        ),
      ),
    );
  }
}

/// When true, _logBrightnessInfo reports both Theme and CupertinoTheme brightness agreeing on light/dark.
/// But then the navbar looks light for some reason, while the text is black on gray, and the divider is a light gray.
///
/// When false, in dark mode, the theme brightness is light, while the cupertino is dark.
/// This leads to rendering black text on a black background.
///
/// No matter what, the default text style color chosen is the light version. I don't get it.
var shouldWrapTheme = false;
Widget wrapWithBrightnessAwareTheme({BuildContext context, Widget child}) => !shouldWrapTheme
    ? child
    : Theme(
        data: MediaQuery.platformBrightnessOf(context) == Brightness.light
            ? ThemeData.light()
            : ThemeData.dark(),
        child: child,
      );

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = [];

  // Style seems to be getting completely ignored. No color or font size changes are seen!
  // A-hah, needed to do a full stop and relaunch. That is very unfortunate for trying to tweak styles live!
  final TextStyle _biggerFont = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 12),
            itemBuilder: (BuildContext context, int i) {
              if (i.isOdd) {
                return Divider();
              }

              final int wordPairIndex = i ~/ 2;
              if (wordPairIndex >= _suggestions.length) {
                _suggestions.addAll(generateWordPairs().take(10));
              }

              final wordPair = _suggestions[wordPairIndex];
              var text = Text(wordPair.asPascalCase /*, style: _biggerFont*/);
              if (wordPairIndex == 1) {
                _logBrightnessInfo(context, text);
              }
              // ListTile is a Material component. It requires a Material in the tree above it. We don't have one, so just use a Row instead.
              return Row(children: [text]);
            }));
  }

  Text _logBrightnessInfo(BuildContext context, Text value) {
    final query = MediaQuery.of(context);
    log('query brightness: ${query.platformBrightness}');
    log('text color is: ${value.style?.color}');
    log('default text style color is: ${DefaultTextStyle.of(context).style.color}');
    log('Theme brightness is: ${Theme.of(context).brightness}');
    log('Cupertino brightness is: ${CupertinoTheme.brightnessOf(context)}');
    return value;
  }
}
