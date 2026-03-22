import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/calculation_record.dart';
import '../services/expression_parser.dart';

class CalculatorProvider extends ChangeNotifier {
  CalculatorProvider({ExpressionParser? parser})
    : _parser = parser ?? ExpressionParser();

  final ExpressionParser _parser;
  final NumberFormat _numberFormatter = NumberFormat('#,##0.##########');

  String _expression = '';
  String _result = '0';
  bool _isDarkMode = true;
  final List<CalculationRecord> _history = [];

  String get expression => _expression.isEmpty ? '0' : _expression;
  String get result => _result;
  bool get isDarkMode => _isDarkMode;
  List<CalculationRecord> get history => List.unmodifiable(_history);

  static const Set<String> _operators = {'+', '-', '×', '÷'};

  /// Handles numeric, decimal, and operator inputs from the keypad.
  void inputValue(String value) {
    if (value == '.') {
      _appendDecimal();
      return;
    }

    if (_operators.contains(value)) {
      _appendOperator(value);
      return;
    }

    _expression += value;
    notifyListeners();
  }

  /// Resets expression and result.
  void clearAll() {
    _expression = '';
    _result = '0';
    notifyListeners();
  }

  /// Clears only the current entry (the right-most number segment).
  void clearEntry() {
    if (_expression.isEmpty) {
      return;
    }

    var end = _expression.length - 1;
    while (end >= 0 && !_operators.contains(_expression[end])) {
      end--;
    }

    _expression = end >= 0 ? _expression.substring(0, end + 1) : '';
    if (_expression.isEmpty) {
      _result = '0';
    }
    notifyListeners();
  }

  /// Deletes one character from the expression.
  void backspace() {
    if (_expression.isEmpty) {
      return;
    }

    _expression = _expression.substring(0, _expression.length - 1);
    if (_expression.isEmpty) {
      _result = '0';
    }
    notifyListeners();
  }

  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Evaluates the expression and stores a history record on success.
  void evaluate() {
    if (_expression.isEmpty) {
      return;
    }

    try {
      final evaluation = _parser.evaluate(_expression);
      final formatted = _format(evaluation);
      _history.insert(
        0,
        CalculationRecord(expression: _expression, result: formatted),
      );
      _result = formatted;
      _expression = formatted;
    } on FormatException catch (error) {
      _result = error.message;
    } catch (_) {
      _result = 'Error';
    }

    notifyListeners();
  }

  void useHistory(CalculationRecord record) {
    _expression = record.result;
    _result = record.result;
    notifyListeners();
  }

  void _appendDecimal() {
    final currentEntry = _currentEntry();
    if (currentEntry.contains('.')) {
      return;
    }

    if (currentEntry.isEmpty || _operators.contains(currentEntry)) {
      _expression += '0.';
    } else {
      _expression += '.';
    }
    notifyListeners();
  }

  void _appendOperator(String operator) {
    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = '-';
        notifyListeners();
      }
      return;
    }

    final last = _expression[_expression.length - 1];
    if (_operators.contains(last)) {
      _expression =
          '${_expression.substring(0, _expression.length - 1)}$operator';
    } else {
      _expression += operator;
    }

    notifyListeners();
  }

  String _currentEntry() {
    if (_expression.isEmpty) {
      return '';
    }

    final pieces = _expression.split(RegExp(r'[+\-×÷]'));
    return pieces.isEmpty ? '' : pieces.last;
  }

  String _format(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return _numberFormatter.format(value);
  }
}
