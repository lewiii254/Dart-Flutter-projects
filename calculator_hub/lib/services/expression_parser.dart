/// Parses and evaluates calculator expressions using:
/// 1) tokenization
/// 2) infix -> postfix conversion (Shunting-yard)
/// 3) postfix evaluation
class ExpressionParser {
  static const Set<String> _operators = {'+', '-', '*', '/'};
  static const Set<String> _parentheses = {'(', ')'};
  static const String _percent = '%';

  double evaluate(String expression) {
    if (expression.trim().isEmpty) {
      throw const FormatException('Empty expression');
    }

    final tokens = _tokenize(expression);
    final postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  List<String> _tokenize(String expression) {
    final normalized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (var index = 0; index < normalized.length; index++) {
      final char = normalized[index];

      if (_isDigit(char) || char == '.') {
        buffer.write(char);
        continue;
      }

      if (_operators.contains(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }

        final previous = tokens.isEmpty ? null : tokens.last;
        final isUnaryMinus =
            char == '-' &&
            (previous == null ||
                _operators.contains(previous) ||
                previous == '(');

        if (isUnaryMinus) {
          buffer.write(char);
        } else {
          tokens.add(char);
        }
        continue;
      }

      if (_parentheses.contains(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }

        tokens.add(char);
        continue;
      }

      if (char == _percent) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }

        tokens.add(_percent);
        continue;
      }

      if (char.trim().isEmpty) {
        continue;
      }

      throw FormatException('Invalid character: $char');
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    if (tokens.isEmpty || _operators.contains(tokens.last) || tokens.last == '(') {
      throw const FormatException('Incomplete expression');
    }

    var openParenthesis = 0;
    for (final token in tokens) {
      if (_operators.contains(token) || token == _percent) {
        continue;
      }

      if (token == '(') {
        openParenthesis++;
        continue;
      }

      if (token == ')') {
        openParenthesis--;
        if (openParenthesis < 0) {
          throw const FormatException('Mismatched parentheses');
        }
        continue;
      }

      final number = double.tryParse(token);
      if (number == null) {
        throw FormatException('Invalid number: $token');
      }
    }

    if (openParenthesis != 0) {
      throw const FormatException('Mismatched parentheses');
    }

    return tokens;
  }

  List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final operatorStack = <String>[];

    for (final token in tokens) {
      if (!_operators.contains(token) && !_parentheses.contains(token) && token != _percent) {
        output.add(token);
        continue;
      }

      if (token == _percent) {
        output.add(token);
        continue;
      }

      if (token == '(') {
        operatorStack.add(token);
        continue;
      }

      if (token == ')') {
        while (operatorStack.isNotEmpty && operatorStack.last != '(') {
          output.add(operatorStack.removeLast());
        }

        if (operatorStack.isEmpty || operatorStack.last != '(') {
          throw const FormatException('Mismatched parentheses');
        }

        operatorStack.removeLast();
        continue;
      }

      while (operatorStack.isNotEmpty &&
          operatorStack.last != '(' &&
          _precedence(operatorStack.last) >= _precedence(token)) {
        output.add(operatorStack.removeLast());
      }

      operatorStack.add(token);
    }

    while (operatorStack.isNotEmpty) {
      if (operatorStack.last == '(') {
        throw const FormatException('Mismatched parentheses');
      }
      output.add(operatorStack.removeLast());
    }

    return output;
  }

  double _evaluatePostfix(List<String> postfix) {
    final stack = <double>[];

    for (final token in postfix) {
      if (!_operators.contains(token) && token != _percent) {
        stack.add(double.parse(token));
        continue;
      }

      if (token == _percent) {
        if (stack.isEmpty) {
          throw const FormatException('Malformed expression');
        }

        final value = stack.removeLast();
        stack.add(value / 100);
        continue;
      }

      if (stack.length < 2) {
        throw const FormatException('Malformed expression');
      }

      final right = stack.removeLast();
      final left = stack.removeLast();

      switch (token) {
        case '+':
          stack.add(left + right);
        case '-':
          stack.add(left - right);
        case '*':
          stack.add(left * right);
        case '/':
          if (right == 0) {
            throw const FormatException('Cannot divide by zero');
          }
          stack.add(left / right);
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Malformed expression');
    }

    return stack.single;
  }

  int _precedence(String operator) {
    switch (operator) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      default:
        return 0;
    }
  }

  bool _isDigit(String value) => value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
}
