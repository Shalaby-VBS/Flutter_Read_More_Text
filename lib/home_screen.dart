import 'package:description_text/read_more_text.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Read More Text")),
      body: const Padding(
        padding: EdgeInsets.all(10),
        child: ReadMoreText(
          '''Egypt is a country located in the northeastern corner of Africa and the southwestern corner of Asia. It is known for its rich history, ancient civilization, and cultural heritage. Here's a brief overview of Egypt.''',
          maxLines: 2,
          trimMode: TrimMode.line,
          textStyle: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
