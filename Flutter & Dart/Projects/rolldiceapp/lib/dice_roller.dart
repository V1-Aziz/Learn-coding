import 'dart:math';
import 'package:flutter/material.dart';

final randomizer = Random();

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});
  @override
  State<DiceRoller> createState() {
    return _DiceRollerState();
  }
}

class _DiceRollerState extends State<DiceRoller> {
  var currentDiceRoll = 2;

  void rolldice() {
    setState(() {
      currentDiceRoll = randomizer.nextInt(6) + 1;
    });
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            rolldice();
          },
          child: Text("Press me"),
        ),
        Image.asset('assets/images/dice-$currentDiceRoll.png', scale: 4),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: rolldice,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 225, 225, 225),
            foregroundColor: const Color.fromARGB(255, 23, 15, 255),
            textStyle: TextStyle(fontSize: 30),
          ),
          child: Text("Roll Dice"),
        ),
      ],
    );
  }
}
