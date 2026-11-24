const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatMoney(double v) => 'RM ${v.toStringAsFixed(2)}';

String formatMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

const List<String> _monthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatMonthLong(DateTime d) => '${_monthsLong[d.month - 1]} ${d.year}';
