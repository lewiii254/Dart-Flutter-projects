import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calculator Hub'),
            actions: [
              IconButton(
                tooltip: 'Toggle theme',
                onPressed: provider.toggleThemeMode,
                icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CalculatorDisplay(
                    expression: provider.expression,
                    result: provider.result,
                    onSwipeDelete: provider.backspace,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: [
                        _button(
                          label: 'AC',
                          isAccent: true,
                          onTap: () => _onPress(provider, provider.clearAll),
                        ),
                        _button(
                          label: 'C',
                          isAccent: true,
                          onTap: () => _onPress(provider, provider.clearEntry),
                        ),
                        _button(
                          label: '',
                          icon: Icons.backspace_outlined,
                          isAccent: true,
                          onTap: () => _onPress(provider, provider.backspace),
                        ),
                        _button(
                          label: '÷',
                          isAccent: true,
                          onTap: () => _onPress(provider, () => provider.inputValue('÷')),
                        ),
                        _button(label: '7', onTap: () => _onPress(provider, () => provider.inputValue('7'))),
                        _button(label: '8', onTap: () => _onPress(provider, () => provider.inputValue('8'))),
                        _button(label: '9', onTap: () => _onPress(provider, () => provider.inputValue('9'))),
                        _button(
                          label: '×',
                          isAccent: true,
                          onTap: () => _onPress(provider, () => provider.inputValue('×')),
                        ),
                        _button(label: '4', onTap: () => _onPress(provider, () => provider.inputValue('4'))),
                        _button(label: '5', onTap: () => _onPress(provider, () => provider.inputValue('5'))),
                        _button(label: '6', onTap: () => _onPress(provider, () => provider.inputValue('6'))),
                        _button(
                          label: '-',
                          isAccent: true,
                          onTap: () => _onPress(provider, () => provider.inputValue('-')),
                        ),
                        _button(label: '1', onTap: () => _onPress(provider, () => provider.inputValue('1'))),
                        _button(label: '2', onTap: () => _onPress(provider, () => provider.inputValue('2'))),
                        _button(label: '3', onTap: () => _onPress(provider, () => provider.inputValue('3'))),
                        _button(
                          label: '+',
                          isAccent: true,
                          onTap: () => _onPress(provider, () => provider.inputValue('+')),
                        ),
                        _button(label: '0', onTap: () => _onPress(provider, () => provider.inputValue('0'))),
                        _button(label: '.', onTap: () => _onPress(provider, () => provider.inputValue('.'))),
                        _button(
                          label: '=',
                          isEquals: true,
                          onTap: () => _onPress(provider, provider.evaluate),
                        ),
                        _HistoryButton(provider: provider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _button({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool isAccent = false,
    bool isEquals = false,
  }) {
    return CalculatorButton(
      label: label,
      icon: icon,
      onTap: onTap,
      isAccent: isAccent,
      isEquals: isEquals,
    );
  }

  void _onPress(CalculatorProvider provider, VoidCallback action) {
    HapticFeedback.lightImpact();
    action();
  }
}

class _HistoryButton extends StatelessWidget {
  const _HistoryButton({required this.provider});

  final CalculatorProvider provider;

  @override
  Widget build(BuildContext context) {
    return CalculatorButton(
      label: '',
      icon: Icons.history,
      isAccent: true,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (_) => SafeArea(
          child: provider.history.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No history yet')))
              : ListView.separated(
                  itemCount: provider.history.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final record = provider.history[index];
                    return ListTile(
                      title: Text(record.expression),
                      subtitle: Text(record.result),
                      trailing: const Icon(Icons.north_west),
                      onTap: () {
                        provider.useHistory(record);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
