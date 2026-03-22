import 'dart:ui';

import 'package:flutter/material.dart';

class CalculatorButton extends StatefulWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.icon,
    this.isAccent = false,
    this.isEquals = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isAccent;
  final bool isEquals;

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.96 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: widget.isEquals
                    ? const LinearGradient(
                        colors: [Color(0xFF6E56FF), Color(0xFF00C2FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isEquals
                    ? null
                    : widget.isAccent
                        ? colors.primary.withValues(alpha: 0.2)
                        : colors.surface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.onSurface.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isEquals
                        ? const Color(0xFF6E56FF).withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.22),
                    blurRadius: widget.isEquals ? 18 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: widget.icon != null
                    ? Icon(widget.icon, size: 24)
                    : Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.isEquals ? Colors.white : null,
                            ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
