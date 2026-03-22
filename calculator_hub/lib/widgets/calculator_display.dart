import 'package:flutter/material.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    required this.memoryLabel,
    required this.onSwipeDelete,
  });

  final String expression;
  final String result;
  final String memoryLabel;
  final VoidCallback onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onHorizontalDragEnd: (_) => onSwipeDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.25),
              colors.surface.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: colors.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    memoryLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  'Swipe to delete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              expression,
              maxLines: 2,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.72),
                  ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                result,
                key: ValueKey(result),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
