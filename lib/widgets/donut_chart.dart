import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'empty_state.dart';

/// Draws a donut (ring) chart with a CustomPainter - no extra packages needed.
class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double progress; // 0..1 for the draw-in animation
  final double strokeWidth;

  DonutChartPainter({
    required this.values,
    required this.colors,
    required this.progress,
    this.strokeWidth = 26,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return;
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), radius: radius);
    final gap = values.length > 1 ? 0.03 : 0.0;
    double start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = colors[i];
      final drawSweep = math.max(sweep - gap, 0.0);
      if (drawSweep > 0) {
        canvas.drawArc(rect, start, drawSweep, false, paint);
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter old) =>
      old.progress != progress || old.values != values || old.colors != colors;
}

/// Card showing spending split by category, as a donut + legend with percentages.
/// Pass in the data (category name -> amount) for whatever period you want.
class CategoryDonutCard extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final String? subtitle;

  const CategoryDonutCard({
    super.key,
    required this.data,
    this.title = 'Spending by category',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (s, e) => s + e.value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Center(
              child: EmptyState(
                icon: Icons.donut_large,
                message: 'No spending recorded for this period.\nYour chart will appear here.',
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: DonutChartPainter(
                          values: entries.map((e) => e.value).toList(),
                          colors: entries.map((e) => categoryByName(e.key).color).toList(),
                          progress: value,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total spent',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(formatMoney(total),
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...entries.map((e) {
              final info = categoryByName(e.key);
              final share = total <= 0 ? 0.0 : e.value / total;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ),
                    Text('${(share * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Text(formatMoney(e.value),
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppColors.textMuted)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
