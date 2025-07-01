import 'package:flutter/material.dart';
import 'package:focalix/imagechat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'F O C A L I X',
      theme: ThemeData.dark(useMaterial3: true),
      home:  ImageChat(),
    );
  }
}