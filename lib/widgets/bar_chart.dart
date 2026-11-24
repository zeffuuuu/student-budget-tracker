import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Grouped bar chart (income vs expense) drawn with a CustomPainter.
class BarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> income;
  final List<double> expense;
  final int labelEvery;
  final double progress;

  BarChartPainter({
    required this.labels,
    required this.income,
    required this.expense,
    required this.labelEvery,
    required this.progress,
  });

  void _text(Canvas canvas, String text, Offset at, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? Offset(at.dx - tp.width / 2, at.dy) : at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const topPad = 16.0;
    const bottomPad = 22.0;
    final chartH = size.height - topPad - bottomPad;

    var maxV = 0.0;
    for (final v in [...income, ...expense]) {
      maxV = math.max(maxV, v);
    }
    final top = maxV <= 0 ? 1.0 : maxV;

    final grid = Paint()
      ..color = const Color(0xFFE5E9F0)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = topPad + chartH * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    _text(canvas, formatMoney(top), const Offset(0, 0));

    final n = labels.length;
    if (n == 0) return;
    final groupW = size.width / n;
    final barW = math.min(groupW * 0.34, 14.0);
    final incPaint = Paint()..color = AppColors.income;
    final expPaint = Paint()..color = AppColors.expense;
    const radius = Radius.circular(3);

    for (var i = 0; i < n; i++) {
      final cx = groupW * i + groupW / 2;
      var ih = income[i] / top * chartH * progress;
      var eh = expense[i] / top * chartH * progress;
      if (income[i] > 0) ih = math.max(ih, 2);
      if (expense[i] > 0) eh = math.max(eh, 2);
      if (ih > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
              Rect.fromLTWH(cx - barW - 1, topPad + chartH - ih, barW, ih),
              topLeft: radius, topRight: radius),
          incPaint,
        );
      }
      if (eh > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
              Rect.fromLTWH(cx + 1, topPad + chartH - eh, barW, eh),
              topLeft: radius, topRight: radius),
          expPaint,
        );
      }
      if (i % labelEvery == 0) {
        _text(canvas, labels[i], Offset(cx, size.height - bottomPad + 5), center: true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter old) => true;
}

class IncomeExpenseBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> income;
  final List<double> expense;
  final int labelEvery;

  const IncomeExpenseBarChart({
    super.key,
    required this.labels,
    required this.income,
    required this.expense,
    this.labelEvery = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: BarChartPainter(
            labels: labels,
            income: income,
            expense: expense,
            labelEvery: labelEvery,
            progress: value,
          ),
        ),
      ),
    );
  }
}
