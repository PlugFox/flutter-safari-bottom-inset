// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:js_interop';

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

  @override
  void initState() {
    super.initState();

    // Инициализируем baseline после первого кадра, когда все DOM-элементы готовы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vv = web.window.visualViewport;
      _baselineHeight = (vv?.height ?? web.window.innerHeight.toDouble());
      vv?.addEventListener(
        'resize',
        (event) {
          _onViewportResize();
        }.toJS,
      );
      /* vv?.onresize =
          (event) {
            _onViewportResize();
          }.toJS; */
    });
  }

  void _onViewportResize() {
    final vv = web.window.visualViewport;
    final current = vv?.height ?? web.window.innerHeight.toDouble();
    final diff = _baselineHeight - current;
    final isOpen = diff > 150;

    print(
      'Viewport resized: '
      'currentHeight=$current, '
      'diff=$diff, '
      'isOpen=$isOpen',
    );

    // Если клавиатура закрылась — обновляем baseline, иначе держим старую высоту
    if (!isOpen) {
      _baselineHeight = current;
    }

    if (isOpen != _keyboardVisible) {
      setState(() {
        _keyboardVisible = isOpen;
        _keyboardHeight = diff.clamp(0.0, double.infinity);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // Disable resizeToAvoidBottomInset on iOS Safari
    // to prevent the keyboard from pushing the content up
    resizeToAvoidBottomInset: !(kIsWeb && defaultTargetPlatform == TargetPlatform.iOS),
    body: AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: _keyboardVisible ? _keyboardHeight : 0),
      child: const SafeArea(
        child: Center(
          child: TextField(decoration: InputDecoration(hintText: 'Нажмите, чтобы открыть клавиатуру в Safari')),
        ),
      ),
    ),
  );
}
