import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  const CategoryInfo(this.name, this.icon, this.color);
}

const List<CategoryInfo> expenseCategories = [
  CategoryInfo('Food', Icons.restaurant, Color(0xFFEF8354)),
  CategoryInfo('Transport', Icons.directions_bus, Color(0xFF4F9DDE)),
  CategoryInfo('Education', Icons.menu_book, Color(0xFF7E57C2)),
  CategoryInfo('Shopping', Icons.shopping_bag, Color(0xFFEC6B9E)),
  CategoryInfo('Leisure', Icons.movie, Color(0xFFFFC72C)),
  CategoryInfo('Bills', Icons.receipt_long, Color(0xFF26A69A)),
  CategoryInfo('Other', Icons.more_horiz, Color(0xFF90A4AE)),
];

const List<CategoryInfo> incomeCategories = [
  CategoryInfo('Allowance', Icons.account_balance_wallet, Color(0xFF18A874)),
  CategoryInfo('Part-time job', Icons.work, Color(0xFF3F8F5F)),
  CategoryInfo('Scholarship', Icons.school, Color(0xFF5C9EAD)),
  CategoryInfo('Other income', Icons.savings, Color(0xFF8BA888)),
];

CategoryInfo categoryByName(String name) {
  for (final c in [...expenseCategories, ...incomeCategories, ...commitmentTypes]) {
    if (c.name == name) return c;
  }
  return expenseCategories.last;
}

/// Types of monthly commitment the user can pick.
const List<CategoryInfo> commitmentTypes = [
  CategoryInfo('Rent', Icons.home, Color(0xFF005ABB)),
  CategoryInfo('Utilities', Icons.bolt, Color(0xFFF59E0B)),
  CategoryInfo('Bills', Icons.receipt_long, Color(0xFF26A69A)),
  CategoryInfo('PayLater', Icons.credit_card, Color(0xFFEC6B9E)),
  CategoryInfo('Loan', Icons.account_balance, Color(0xFF7E57C2)),
  CategoryInfo('Subscription', Icons.subscriptions, Color(0xFF4F9DDE)),
  CategoryInfo('Other', Icons.more_horiz, Color(0xFF90A4AE)),
];

CategoryInfo commitmentTypeByName(String name) {
  for (final c in commitmentTypes) {
    if (c.name == name) return c;
  }
  return commitmentTypes.last;
}
