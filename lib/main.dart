import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:marker_map_eaxmple/marker_map_page.dart';
import 'package:marker_map_eaxmple/using_permisson_handaler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UsingPermissonHandaler(),
    );
  }
}

