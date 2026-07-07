import 'package:flutter/material.dart';
import 'package:quizapp/answer_button.dart';
import "package:quizapp/data/questions.dart";
import 'package:google_fonts/google_fonts.dart';

class QuizQuestions extends StatefulWidget {
  const QuizQuestions({super.key, required this.onSelectedAnswers});

  final void Function(String answer) onSelectedAnswers;

  @override
  State<QuizQuestions> createState() {
    return _QuizQuestions();
  }
}

class _QuizQuestions extends State<QuizQuestions> {
  var currentQuestionIndex = 0;

  void answerQuestion(String selecAnswer) {
    widget.onSelectedAnswers(selecAnswer);
    setState(() {
      currentQuestionIndex++;
    });
  }

  @override
  Widget build(ctx) {
    final currentquestion = questions[currentQuestionIndex];
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentquestion.text,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...currentquestion.getShuffledAnswers().map((answer) {
              return AnswerButton(
                answerText: answer,
                onTap: () {
                  answerQuestion(answer);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
