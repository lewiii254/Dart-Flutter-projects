import 'dart:ui';

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
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calculator Hub'),
            actions: [
              IconButton(
                tooltip: 'Theme',
                onPressed: provider.toggleThemeMode,
                icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              ),
              IconButton(
                tooltip: 'History',
                onPressed: () => _openHistory(context, provider),
                icon: const Icon(Icons.history),
              ),
            ],
          ),
          body: Stack(
            children: [
              const _BackgroundGlow(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        children: [
                          CalculatorDisplay(
                            expression: provider.expression,
                            result: provider.result,
                            memoryLabel: provider.memoryLabel,
                            onSwipeDelete: provider.backspace,
                          ),
                          const SizedBox(height: 14),
                          _QuickTips(provider: provider),
                          const SizedBox(height: 14),
                          Expanded(
                            child: GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.08,
                              children: [
                                _button(label: 'MC', isAccent: true, onTap: () => _onPress(provider, provider.memoryClear)),
                                _button(label: 'MR', isAccent: true, onTap: () => _onPress(provider, provider.memoryRecall)),
                                _button(label: 'M+', isAccent: true, onTap: () => _onPress(provider, provider.memoryAdd)),
                                _button(label: 'M-', isAccent: true, onTap: () => _onPress(provider, provider.memorySubtract)),
                                _button(label: '%', isAccent: true, onTap: () => _onPress(provider, provider.applyPercent)),
                                _button(label: '(', isAccent: true, onTap: () => _onPress(provider, () => provider.inputValue('('))),
                                _button(label: ')', isAccent: true, onTap: () => _onPress(provider, () => provider.inputValue(')'))),
                                _button(label: '±', isAccent: true, onTap: () => _onPress(provider, provider.toggleSign)),
                                _button(label: 'C', isAccent: true, onTap: () => _onPress(provider, provider.clearEntry)),
                                _button(label: 'AC', isAccent: true, onTap: () => _onPress(provider, provider.clearAll)),
                                _button(label: '7', onTap: () => _onPress(provider, () => provider.inputValue('7'))),
                                _button(label: '8', onTap: () => _onPress(provider, () => provider.inputValue('8'))),
                                _button(label: '9', onTap: () => _onPress(provider, () => provider.inputValue('9'))),
                                _button(label: '÷', isAccent: true, onTap: () => _onPress(provider, () => provider.inputValue('÷'))),
                                _button(
                                  label: '',
                                  icon: Icons.backspace_outlined,
                                  isAccent: true,
                                  onLongPress: () => _onPress(provider, provider.clearAll, heavy: true),
                                  onTap: () => _onPress(provider, provider.backspace),
                                ),
                                _button(label: '4', onTap: () => _onPress(provider, () => provider.inputValue('4'))),
                                _button(label: '5', onTap: () => _onPress(provider, () => provider.inputValue('5'))),
                                _button(label: '6', onTap: () => _onPress(provider, () => provider.inputValue('6'))),
                                _button(label: '×', isAccent: true, onTap: () => _onPress(provider, () => provider.inputValue('×'))),
                                _button(
                                  label: '',
                                  icon: Icons.history,
                                  isAccent: true,
                                  onTap: () => _onPress(provider, () => _openHistory(context, provider)),
                                ),
                                _button(label: '1', onTap: () => _onPress(provider, () => provider.inputValue('1'))),
                                _button(label: '2', onTap: () => _onPress(provider, () => provider.inputValue('2'))),
                                _button(label: '3', onTap: () => _onPress(provider, () => provider.inputValue('3'))),
                                _button(label: '-', isAccent: true, onTap: () => _onPress(provider, () => provider.inputValue('-'))),
                                _button(
                                  label: '',
                                  icon: provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  isAccent: true,
                                  onTap: () => _onPress(provider, provider.toggleThemeMode),
                                ),
                                _button(label: '0', onTap: () => _onPress(provider, () => provider.inputValue('0'))),
                                _button(label: '00', onTap: () => _onPress(provider, () => provider.inputValue('00'))),
                                _button(label: '.', onTap: () => _onPress(provider, () => provider.inputValue('.'))),
                                _button(label: '+', isAccent: true, onTap: () => _onPress(provider, () => provider.inputValue('+'))),
                                _button(label: '=', isEquals: true, onTap: () => _onPress(provider, provider.evaluate, heavy: true)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _button({
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    IconData? icon,
    bool isAccent = false,
    bool isEquals = false,
  }) {
    return CalculatorButton(
      label: label,
      icon: icon,
      onTap: onTap,
      onLongPress: onLongPress,
      isAccent: isAccent,
      isEquals: isEquals,
    );
  }

  void _onPress(CalculatorProvider provider, VoidCallback action, {bool heavy = false}) {
    if (heavy) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    action();
  }

  void _openHistory(BuildContext context, CalculatorProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (bottomSheetContext) => SafeArea(
        child: provider.history.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No history yet. Start calculating ✨'),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        const Text('Recent Calculations', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            provider.clearHistory();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.delete_sweep_outlined),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
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
                ],
              ),
      ),
    );
  }
}

class _QuickTips extends StatelessWidget {
  const _QuickTips({required this.provider});

  final CalculatorProvider provider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Use % for quick ratios, long-press ⌫ to reset, and tap history to reuse results.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _GlowBubble(
              size: 280,
              colors: const [Color(0x665066FF), Color(0x003B2FD9)],
            ),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: _GlowBubble(
              size: 320,
              colors: const [Color(0x5538D6FF), Color(0x0038D6FF)],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: const SizedBox.expand(),
      ),
    );
  }
}
