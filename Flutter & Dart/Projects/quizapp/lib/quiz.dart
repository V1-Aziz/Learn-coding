import 'package:flutter/material.dart';
import 'package:quizapp/data/questions.dart';
import 'package:quizapp/questions_screen.dart';
import 'package:quizapp/results_screen.dart';
import 'package:quizapp/widgets.dart';

class Quizes extends StatefulWidget {
  const Quizes({super.key});
  @override
  State<Quizes> createState() {
    return _Quizes();
  }
}

class _Quizes extends State<Quizes> {
  List<String> selectedAnswers = [];
  var activeScreen = 'start-screen';
  void switchScreen() {
    setState(() {
      activeScreen = 'question-screen';
    });
  }

  void chooseAnswer(String answer) {
    selectedAnswers.add(answer);

    if (selectedAnswers.length == questions.length) {
      setState(() {
        activeScreen = 'results-screen';
      });
    }
  }

  void restartQuiz() {
    setState(() {
      selectedAnswers = [];
      activeScreen = 'question-screen';
    });
  }

  @override
  Widget build(ctx) {
    Widget screenWidget = MainPageWidgets(switchScreen);
    if (activeScreen == 'question-screen') {
      screenWidget = QuizQuestions(onSelectedAnswers: chooseAnswer);
    }

    if (activeScreen == 'results-screen') {
      screenWidget = ResultsScreen(
        chosenAnswer: selectedAnswers,
        onReStart: restartQuiz,
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
