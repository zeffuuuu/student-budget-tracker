import 'package:flutter/foundation.dart';
import '../models/commitment.dart';
import '../models/transaction.dart';

/// One registered user. A NEW account always starts completely empty.
class Account {
  final String name;
  final String email;
  final String password;
  double dailyLimit = 50; // impulse alert threshold
  bool alertEnabled = true;
  final List<Transaction> transactions = []; // only what the user keyed in
  final List<Commitment> commitments = [];

  Account({required this.name, required this.email, required this.password});
}

/// Returned when an expense would push the day's spending over the limit.
class ImpulseWarning {
  final double amount;
  final double dayTotal;
  final double limit;
  const ImpulseWarning(
      {required this.amount, required this.dayTotal, required this.limit});

  bool get singleOver => amount > limit;
}

/// In-memory app data (lives while the app is open).
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final Map<String, Account> _accounts = {};
  Account? _current;
  final Account _empty = Account(name: '', email: '', password: '');
  int _idCounter = 0;

  Account get _a => _current ?? _empty;

  String newId() => 'id${_idCounter++}';
  String _key(String email) => email.trim().toLowerCase();

  // ---- accounts ----
  bool get isLoggedIn => _current != null;
  String get userName => _a.name;
  String get userEmail => _a.email;

  /// Returns an error message, or null when the account was created.
  String? register(
      {required String name, required String email, required String password}) {
    final k = _key(email);
    if (_accounts.containsKey(k)) {
      return 'An account with this email already exists';
    }
    _accounts[k] =
        Account(name: name.trim(), email: email.trim(), password: password);
    return null;
  }

  /// Returns an error message, or null on success.
  String? login(String email, String password) {
    final acc = _accounts[_key(email)];
    if (acc == null) {
      return 'No account found for this email. Please register first.';
    }
    if (acc.password != password) return 'Incorrect password';
    _current = acc;
    notifyListeners();
    return null;
  }

  void logout() {
    _current = null;
    notifyListeners();
  }

  // ---- impulse alert settings ----
  double get dailyLimit => _a.dailyLimit;
  bool get alertEnabled => _a.alertEnabled;

  void setDailyLimit(double v) {
    _a.dailyLimit = v;
    notifyListeners();
  }

  void setAlertEnabled(bool v) {
    _a.alertEnabled = v;
    notifyListeners();
  }

  // ---- transactions ----

  /// Expense entries generated automatically from monthly commitments:
  /// one per active month, dated on the 1st of that month, from the month the
  /// commitment starts up to the current month.
  List<Transaction> _commitmentEntries() {
    final now = DateTime.now();
    final out = <Transaction>[];
    for (final c in _a.commitments) {
      var y = c.start.year;
      var m = c.start.month;
      while (y < now.year || (y == now.year && m <= now.month)) {
        if (c.isActiveIn(y, m)) {
          out.add(Transaction(
            id: 'c-${c.id}-$y-$m',
            title: c.name,
            category: c.type,
            amount: c.amount,
            date: DateTime(y, m, 1),
            isExpense: true,
            note: 'Monthly commitment',
            commitmentId: c.id,
          ));
        }
        m++;
        if (m > 12) {
          m = 1;
          y++;
        }
      }
    }
    return out;
  }

  /// Everything the user has spent or earned: keyed-in transactions
  /// PLUS the automatic monthly-commitment expenses. Newest first.
  List<Transaction> get transactions {
    final list = <Transaction>[..._a.transactions, ..._commitmentEntries()];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get totalIncome => transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  bool _isThisMonth(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// This month's spending by category (includes automatic commitments).
  Map<String, double> get monthExpenseByCategory {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.isExpense && _isThisMonth(t.date)) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  void add(Transaction t) {
    _a.transactions.add(t);
    notifyListeners();
  }

  void update(Transaction t) {
    final i = _a.transactions.indexWhere((x) => x.id == t.id);
    if (i != -1) {
      _a.transactions[i] = t;
      notifyListeners();
    }
  }

  void delete(String id) {
    _a.transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ---- impulsive purchase alert (only counts what the user keyed in) ----
  double expenseOnDay(DateTime day, {String? excludeId}) => _a.transactions
      .where((t) => t.isExpense && t.id != excludeId && _sameDay(t.date, day))
      .fold(0.0, (s, t) => s + t.amount);

  double get todayExpense => expenseOnDay(DateTime.now());

  bool get overDailyLimitToday =>
      alertEnabled && dailyLimit > 0 && todayExpense > dailyLimit;

  ImpulseWarning? checkImpulse(
      {required double amount, required DateTime date, String? excludeId}) {
    if (!alertEnabled || dailyLimit <= 0) return null;
    final total = expenseOnDay(date, excludeId: excludeId) + amount;
    if (total > dailyLimit) {
      return ImpulseWarning(amount: amount, dayTotal: total, limit: dailyLimit);
    }
    return null;
  }

  // ---- monthly commitments ----
  List<Commitment> get commitments => List<Commitment>.of(_a.commitments);

  List<Commitment> get activeCommitments {
    final n = DateTime.now();
    return _a.commitments.where((c) => c.isActiveIn(n.year, n.month)).toList();
  }

  double get monthCommitments =>
      activeCommitments.fold(0.0, (s, c) => s + c.amount);

  void addCommitment(Commitment c) {
    _a.commitments.add(c);
    notifyListeners();
  }

  void updateCommitment(Commitment c) {
    final i = _a.commitments.indexWhere((x) => x.id == c.id);
    if (i != -1) {
      _a.commitments[i] = c;
      notifyListeners();
    }
  }

  void deleteCommitment(String id) {
    _a.commitments.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
