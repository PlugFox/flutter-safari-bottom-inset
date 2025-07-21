// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web/web.dart' as web;

void main() => runZonedGuarded<void>(
  () async {
    final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
    runApp(const MyApp());
    SchedulerBinding.instance.addPostFrameCallback((_) {
      binding.allowFirstFrame();
    });
  },
  (error, stack) {
    print('Error in main: $error');
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: KeyboardAwareScaffold());
  }
}

class KeyboardAwareScaffold extends StatefulWidget {
  const KeyboardAwareScaffold({super.key});

  @override
  State<KeyboardAwareScaffold> createState() => _KeyboardAwareScaffoldState();
}

class _KeyboardAwareScaffoldState extends State<KeyboardAwareScaffold> {
  late double _baselineHeight;
  bool _keyboardVisible = false;
  double _keyboardHeight = 0;
  StreamSubscription<web.Event>? _resizeSub;

  static final bool _fixResizeToAvoidBottomInset = kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    resizeToAvoidBottomInsetFix();
  }

  void resizeToAvoidBottomInsetFix() {
    if (!_fixResizeToAvoidBottomInset) return;

    // Initialize baseline height to the current viewport height
    void onViewportResize() {
      final current = web.window.visualViewport?.height;
      if (current == null) return;
      final diff = web.window.innerHeight - current;
      final isOpen = diff > 150; // Arbitrary threshold to determine if the keyboard is open

      print(
        'Viewport resized: '
        'currentHeight=$current, '
        'diff=$diff, '
        'isOpen=$isOpen',
      );

      if (isOpen == _keyboardVisible) return;

      /* if (!isOpen) {
        _baselineHeight = current;
      } */

      setState(() {
        _keyboardVisible = isOpen;
        _keyboardHeight = diff.clamp(0.0, double.infinity);
      });
    }

    // This is a workaround for the issue with Safari on iOS
    // where the keyboard does not resize the viewport correctly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vv = web.window.visualViewport;
      //_baselineHeight = (vv?.height ?? web.window.innerHeight.toDouble());
      if (vv == null) {
        print('VisualViewport is not available');
      }

      /* vv?.addEventListener(
        'resize',
        (event) {
          _onViewportResize();
        }.toJS,
      ); */

      final resizeStream = const web.EventStreamProvider<web.Event>('resize').forTarget(vv);
      _resizeSub = resizeStream.listen((_) => onViewportResize());
      onViewportResize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _resizeSub?.cancel();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // Disable resizeToAvoidBottomInset on iOS Safari
    // to prevent the keyboard from pushing the content up
    resizeToAvoidBottomInset: !_fixResizeToAvoidBottomInset,
    body: AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: _keyboardVisible ? _keyboardHeight : 0),
      child: const SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TextField(decoration: InputDecoration(hintText: 'Click here to show keyboard')),
        ),
      ),
    ),
  );
}
