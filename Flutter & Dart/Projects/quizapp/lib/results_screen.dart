import "package:flutter/material.dart";
import "package:quizapp/data/questions.dart";
import 'package:quizapp/questions_summary.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.chosenAnswer,
    required this.onReStart,
  });
  final void Function() onReStart;
  final List<String> chosenAnswer;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];
    for (var i = 0; i < chosenAnswer.length; i++) {
      summary.add({
        'questions_index': i,
        'question': questions[i].text,
        'correct_answer': questions[i].answers[0],
        'user_answer': chosenAnswer[i],
      });
    }
    return summary;
  }

  @override
  Widget build(context) {
    final summaryData = getSummaryData();
    final numTotalQuestions = questions.length;
    final numCorrectquestions =
        summaryData.where((data) {
          return data['user_answer'] == data['correct_answer'];
        }).length;
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You answered $numCorrectquestions out of $numTotalQuestions question correctly!',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 30),
            QuestionsSummary(summaryData),
            SizedBox(height: 30),
            TextButton.icon(
              onPressed: onReStart,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: Icon(Icons.restart_alt),
              label: Text("Restart quiz!"),
            ),
          ],
        ),
      ),
    );
  }
}
