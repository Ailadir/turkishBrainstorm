import 'package:flutter/material.dart';
import '../../domain/practice_mode.dart';

class GradeButtons extends StatelessWidget {
  final void Function(ReviewGrade) onGrade;
  const GradeButtons({super.key, required this.onGrade});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _GradeBtn(ReviewGrade.again, Colors.red, onGrade),
        _GradeBtn(ReviewGrade.hard, Colors.orange, onGrade),
        _GradeBtn(ReviewGrade.good, Colors.green, onGrade),
        _GradeBtn(ReviewGrade.easy, Colors.blue, onGrade),
      ],
    );
  }
}

class _GradeBtn extends StatelessWidget {
  final ReviewGrade grade;
  final Color color;
  final void Function(ReviewGrade) onGrade;
  const _GradeBtn(this.grade, this.color, this.onGrade);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(72, 44),
      ),
      onPressed: () => onGrade(grade),
      child: Text(
        grade.name[0].toUpperCase() + grade.name.substring(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
