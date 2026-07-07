import 'package:flutter/material.dart';
import 'package:rolldiceapp/dice_roller.dart';

final startAlignment = Alignment.topLeft;
final endAlignment = Alignment.bottomRight;

class GradientContainer extends StatelessWidget {
  const GradientContainer(this.color1, this.color2, this.color3, {super.key});

  const GradientContainer.purple({super.key})
    : color1 = const Color.fromARGB(255, 0, 255, 21),
      color2 = const Color.fromARGB(255, 0, 4, 255),
      color3 = const Color.fromARGB(255, 255, 0, 0);
  final Color color1;
  final Color color2;
  final Color color3;
  
  @override
  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2, color3],
          begin: startAlignment,
          end: endAlignment,
        ),
      ),
      child: Center(child: DiceRoller()),
    );
  }
}
