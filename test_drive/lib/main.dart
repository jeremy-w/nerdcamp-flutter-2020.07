import 'package:flutter/cupertino.dart';

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
        child: const Center(
          child: const Text('Hello World'),
        ),
      ),
    );
  }
}
