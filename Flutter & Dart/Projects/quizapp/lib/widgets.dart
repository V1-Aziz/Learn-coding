import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPageWidgets extends StatelessWidget {
  const MainPageWidgets(this.startQuiz, {super.key});

  final void Function() startQuiz;

  @override
  Widget build(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assests/Images/quiz-logo.png',
            width: 300,
            color: const Color.fromARGB(150, 255, 255, 255),
          ),
          Padding(padding: EdgeInsets.only(top: 40)),
          Text(
            'learn Flutter in the fun way',
            style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          OutlinedButton.icon(
            onPressed: startQuiz,
            icon: Icon(Icons.arrow_right_alt),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            label: Text("Start Quiz"),
          ),
        ],
      ),
    );
  }
}
