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
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(appName),
        ),
        // FIXME: This works fine with light mode, but in dark mode, the text stays dark! And the dividers go black?
        // The navbar text displays fine in both modes, though.

        // FIXME: This is underlapping the navbar.
        child: Center(
          child: RandomWords(),
        ),
      ),
    );
  }
}

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
