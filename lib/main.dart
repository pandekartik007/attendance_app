import 'package:flutter/material.dart';
import './screens/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MaterialColor gray = const MaterialColor(
    0xFF262626,
    const <int, Color>{
      50:  const Color(0xFF262626),
      100: const Color(0xFF262626),
      200: const Color(0xFF262626),
      300: const Color(0xFF262626),
      400: const Color(0xFF262626),
      500: const Color(0xFF262626),
      600: const Color(0xFF262626),
      700: const Color(0xFF262626),
      800: const Color(0xFF262626),
      900: const Color(0xFF262626),
    },
  );

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Attendance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: gray
      ),
      home: NoteList(),
    );
  }
}

