import 'package:flutter/material.dart';

import '../models/todo_task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.onChanged,
    required this.onEdit,
    super.key,
  });

  final TodoTask task;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;

  Color _priorityColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (task.priority) {
      case TaskPriority.low:
        return scheme.secondary;
      case TaskPriority.medium:
        return scheme.primary;
      case TaskPriority.high:
        return scheme.error;
    }
  }

  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) => onChanged(value ?? false),
          ),
          title: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityColor(context).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_rounded,
                          size: 14, color: _priorityColor(context)),
                      const SizedBox(width: 4),
                      Text(_priorityLabel,
                          style: TextStyle(color: scheme.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
            tooltip: 'Edit task',
          ),
        ),
      ),
    );
  }
}
