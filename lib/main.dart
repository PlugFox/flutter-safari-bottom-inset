import 'dart:async';

import 'package:flutter/material.dart';

void main() => runZonedGuarded<void>(
  () async {
    runApp(const App());
  },
  (error, stackTrace) => print('Top level exception: $error\n$stackTrace'), // ignore: avoid_print
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(title: 'Material App', home: Screen());
}

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('0.0.1'), centerTitle: true),
    resizeToAvoidBottomInset: true, // Adjusts the body when the keyboard is shown
    body: SafeArea(
      maintainBottomViewPadding: true, // Keeps the bottom padding when the keyboard is shown
      child: Stack(
        children: <Widget>[
          Align(
            alignment: const Alignment(0.0, 0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Padding: ${MediaQuery.paddingOf(context)}', overflow: TextOverflow.ellipsis),
                Text('View padding: ${MediaQuery.viewPaddingOf(context)}', overflow: TextOverflow.ellipsis),
                Text('View insets: ${MediaQuery.viewInsetsOf(context)}', overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Type something', border: OutlineInputBorder()),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
