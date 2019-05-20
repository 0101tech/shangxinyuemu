import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'view/index.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

const title = '赏心悦目';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF4A8CFF),
      ),
      home: Index(title),
    );
  }
}
