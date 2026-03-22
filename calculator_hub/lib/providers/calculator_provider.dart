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
  double _memoryValue = 0;
  bool _isDarkMode = true;
  final List<CalculationRecord> _history = [];

  String get expression => _expression.isEmpty ? '0' : _expression;
  String get result => _result;
  String get memoryLabel => _memoryValue == 0 ? 'M: empty' : 'M: ${_format(_memoryValue)}';
  bool get isDarkMode => _isDarkMode;
  List<CalculationRecord> get history => List.unmodifiable(_history);

  static const Set<String> _operators = {'+', '-', '×', '÷'};

  /// Handles numeric, decimal, and operator inputs from the keypad.
  void inputValue(String value) {
    if (value == '(' || value == ')') {
      _appendParenthesis(value);
      return;
    }

    if (value == '.') {
      _appendDecimal();
      return;
    }

    if (_operators.contains(value)) {
      _appendOperator(value);
      return;
    }

    _expression += value;
    _refreshPreview();
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
    _refreshPreview();
    notifyListeners();
  }

  /// Deletes one character from the expression.
  void backspace() {
    if (_expression.isEmpty) {
      return;
    }

    _expression = _expression.substring(0, _expression.length - 1);
    _refreshPreview();
    notifyListeners();
  }

  void toggleSign() {
    if (_expression.isEmpty) {
      _expression = '-';
      notifyListeners();
      return;
    }

    final start = _lastEntryStart();
    if (start < 0 || start >= _expression.length) {
      return;
    }

    final entry = _expression.substring(start);
    if (entry.startsWith('-')) {
      _expression = '${_expression.substring(0, start)}${entry.substring(1)}';
    } else {
      _expression = '${_expression.substring(0, start)}-$entry';
    }

    _refreshPreview();
    notifyListeners();
  }

  void applyPercent() {
    if (_expression.isEmpty) {
      return;
    }

    final last = _expression[_expression.length - 1];
    if (_operators.contains(last) || last == '(' || last == '.') {
      return;
    }

    _expression += '%';
    _refreshPreview();
    notifyListeners();
  }

  void memoryAdd() {
    _memoryValue += _evaluateCurrentOrResult();
    notifyListeners();
  }

  void memorySubtract() {
    _memoryValue -= _evaluateCurrentOrResult();
    notifyListeners();
  }

  void memoryRecall() {
    final recalled = _toExpressionNumber(_memoryValue);
    if (_expression.isEmpty || _operators.contains(_expression[_expression.length - 1]) || _expression.endsWith('(')) {
      _expression += recalled;
    } else {
      _expression = recalled;
    }

    _refreshPreview();
    notifyListeners();
  }

  void memoryClear() {
    _memoryValue = 0;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
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
      final rawExpression = _expression;
      final evaluation = _parser.evaluate(_sanitizeExpression(_expression));
      final formatted = _format(evaluation);
      _history.insert(
        0,
        CalculationRecord(expression: rawExpression, result: formatted),
      );
      _result = formatted;
      _expression = _toExpressionNumber(evaluation);
    } on FormatException catch (error) {
      _result = error.message;
    } catch (_) {
      _result = 'Error';
    }

    notifyListeners();
  }

  void useHistory(CalculationRecord record) {
    _expression = _sanitizeExpression(record.expression);
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
    _refreshPreview();
    notifyListeners();
  }

  void _appendOperator(String operator) {
    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = '-';
        _refreshPreview();
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

    _refreshPreview();
    notifyListeners();
  }

  void _appendParenthesis(String parenthesis) {
    if (parenthesis == '(') {
      if (_expression.isEmpty || _operators.contains(_expression[_expression.length - 1]) || _expression.endsWith('(')) {
        _expression += '(';
      } else {
        _expression += '×(';
      }

      notifyListeners();
      return;
    }

    final open = '('.allMatches(_expression).length;
    final close = ')'.allMatches(_expression).length;
    if (open > close && _expression.isNotEmpty && !_operators.contains(_expression[_expression.length - 1]) && !_expression.endsWith('(')) {
      _expression += ')';
      _refreshPreview();
      notifyListeners();
    }
  }

  String _currentEntry() {
    if (_expression.isEmpty) {
      return '';
    }

    final pieces = _expression.split(RegExp(r'[+\-×÷()]'));
    return pieces.isEmpty ? '' : pieces.last;
  }

  int _lastEntryStart() {
    for (var index = _expression.length - 1; index >= 0; index--) {
      final char = _expression[index];
      if (_operators.contains(char) || char == '(' || char == ')') {
        return index + 1;
      }
    }

    return 0;
  }

  void _refreshPreview() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }

    final last = _expression[_expression.length - 1];
    if (_operators.contains(last) || last == '(' || last == '.') {
      return;
    }

    try {
      final value = _parser.evaluate(_sanitizeExpression(_expression));
      _result = _format(value);
    } catch (_) {
      // Keep the previous result until expression becomes valid again.
    }
  }

  double _evaluateCurrentOrResult() {
    try {
      if (_expression.isNotEmpty) {
        return _parser.evaluate(_sanitizeExpression(_expression));
      }
      return double.parse(_sanitizeExpression(_result));
    } catch (_) {
      return 0;
    }
  }

  String _sanitizeExpression(String value) {
    return value
        .replaceAll(',', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
  }

  String _toExpressionNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value.toStringAsPrecision(12).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _format(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return _numberFormatter.format(value);
  }
}
