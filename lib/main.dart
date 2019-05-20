import 'package:flutter/material.dart';

import 'view/index.dart';

void main() => runApp(MyApp());

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
