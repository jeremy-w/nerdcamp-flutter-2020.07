import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Welcome to Flutter',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Welcome to Flutter'),
        ),
        // FIXME: This works fine with light mode, but in dark mode, the text stays dark!
        // The navbar text displays fine in both modes, though.
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
    final wordPair = WordPair.random();
    final query = MediaQuery.of(context);
    log('query brightness: ${query.platformBrightness}');
    final value = Text(wordPair.asPascalCase, style: _biggerFont);
    log('text color is: ${value.style.color}');
    log('default text style color is: ${DefaultTextStyle.of(context).style.color}');
    log('Theme brightness is: ${Theme.of(context).brightness}');
    log('Cupertino brightness is: ${CupertinoTheme.brightnessOf(context)}');
    return value;
  }
}
