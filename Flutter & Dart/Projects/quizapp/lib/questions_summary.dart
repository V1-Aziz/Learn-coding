import 'package:flutter/material.dart';

class QuestionsSummary extends StatelessWidget {
  final List<Map<String, Object>> summaryData;
  const QuestionsSummary(this.summaryData, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: summaryData.map((data) {
            // Determine if the answer is correct
            final isCorrect = data['user_answer'] == data['correct_answer'];
            final circleColor = isCorrect ? Colors.green : Colors.red;

            return Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    ((data['questions_index'] as int) + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['question'] as String),
                      Text(
                        'Your answer: ${data['user_answer']}',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                      Text('Correct answer: ${data['correct_answer']}'),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}