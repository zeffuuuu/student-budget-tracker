import '../utils/format.dart';

/// A fixed monthly payment (rent, utilities, bills, PayLater...).
/// It is added to the user's spending automatically every month while it is
/// active. [months] = how many months it lasts (the user can type months or
/// years, years are stored as months). null = forever.
class Commitment {
  final String id;
  final String name;
  final String type;
  final double amount;
  final DateTime start; // first month it applies (day is ignored)
  final int? months;

  const Commitment({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.start,
    required this.months,
  });

  int _index(int year, int month) =>
      (year - start.year) * 12 + (month - start.month);

  bool isActiveIn(int year, int month) {
    final i = _index(year, month);
    if (i < 0) return false;
    return months == null || i < months!;
  }

  DateTime? get endMonth =>
      months == null ? null : DateTime(start.year, start.month + months! - 1);

  String get durationLabel {
    if (months == null) return 'Forever';
    final m = months!;
    if (m % 12 == 0) {
      final y = m ~/ 12;
      return y == 1 ? '1 year' : '$y years';
    }
    return m == 1 ? '1 month' : '$m months';
  }

  String statusLabel(int year, int month) {
    final i = _index(year, month);
    if (i < 0) return 'Starts ${formatMonthYear(start)}';
    if (months == null) return 'Ongoing';
    if (i >= months!) return 'Ended ${formatMonthYear(endMonth!)}';
    return 'Ends ${formatMonthYear(endMonth!)}';
  }
}
