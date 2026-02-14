import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/currency_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Budget> _budgets = [];
  String _currency = 'USD';
  Map<String, double> _exchangeRates = {};
  bool _isDarkMode = false;

  List<Expense> get expenses => [..._expenses];
  List<Budget> get budgets => [..._budgets];
  String get currency => _currency;
  bool get isDarkMode => _isDarkMode;
double get totalAmount {
  return _expenses.fold(
      0.0, (sum, expense) => sum + expense.amount);
}


  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> decoded = json.decode(expensesJson);
      _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
    }

    final budgetsJson = prefs.getString('budgets');
    if (budgetsJson != null) {
      final List<dynamic> decoded = json.decode(budgetsJson);
      _budgets = decoded.map((item) => Budget.fromJson(item)).toList();
    }

    _currency = prefs.getString('currency') ?? 'USD';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    notifyListeners();
    await loadExchangeRates();
  }

  Future<void> clearAllExpenses() async {
    _expenses.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('expenses');

    notifyListeners();
  }

  Future<void> loadExchangeRates() async {
    try {
      final currencyService = CurrencyService();
      _exchangeRates = await currencyService.getExchangeRates();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load exchange rates: $e');
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = json.encode(
      _expenses.map((expense) => expense.toJson()).toList(),
    );
    await prefs.setString('expenses', expensesJson);
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = json.encode(
      _budgets.map((budget) => budget.toJson()).toList(),
    );
    await prefs.setString('budgets', budgetsJson);
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    notifyListeners();
    await _saveExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
      await _saveExpenses();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
    await _saveExpenses();
  }

  Future<void> setCurrency(String newCurrency) async {
    _currency = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Map<String, double> getCategoryTotals({DateTime? month}) {
    final Map<String, double> totals = {};

    var filteredExpenses = _expenses;
    if (month != null) {
      filteredExpenses = _expenses
          .where((expense) =>
              expense.date.year == month.year &&
              expense.date.month == month.month)
          .toList();
    }

    for (var expense in filteredExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  List<Expense> getExpensesByMonth(DateTime month) {
    return _expenses
        .where((expense) =>
            expense.date.year == month.year &&
            expense.date.month == month.month)
        .toList();
  }

  double getMonthTotal(DateTime month) {
    return getExpensesByMonth(month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

double convertAmount(double amount) {
  if (_currency == 'USD' || _exchangeRates.isEmpty) {
    return amount;
  }

  final rate = _exchangeRates[_currency];
  if (rate == null) return amount;

  return amount * rate;
}


  String exportData() {
    final data = {
      'expenses': _expenses.map((e) => e.toJson()).toList(),
      'budgets': _budgets.map((b) => b.toJson()).toList(),
      'currency': _currency,
      'exportDate': DateTime.now().toIso8601String(),
    };
    return json.encode(data);
  }

  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    return {
      'totalExpenses': _expenses.length,
      'totalAmount': totalAmount,
      'thisMonthTotal': getMonthTotal(thisMonth),
      'lastMonthTotal': getMonthTotal(lastMonth),
      'averageExpense': _expenses.isEmpty ? 0 : totalAmount / _expenses.length,
    };
  }
}
