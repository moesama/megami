import 'package:flutter/material.dart';

import 'package:megami/style.dart';
import 'package:megami/style_exts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    styleCubit.setStyle(
        '.body { background: url(https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=260909750,699257828&fm=15&gp=0.jpg); border: 3pt solid rgba(128, 128, 255, 1); border-radius: 10pt 20pt; padding: 5pt 14pt; } ');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StyledScaffold(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Container(
              color: Colors.amber,
              child: Center(
                child: TextField().styled(".body"),
              ),
            ),
          );
        }
      ),
    );
  }
}
