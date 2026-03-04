import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

enum TaskFilter { all, active, completed }

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final TextEditingController _searchController = TextEditingController();
  TaskFilter _filter = TaskFilter.all;
  TaskPriority? _priorityFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TodoTask> _filteredTasks(List<TodoTask> tasks) {
    var result = tasks.toList();

    if (_filter == TaskFilter.active) {
      result = result.where((task) => !task.isCompleted).toList();
    } else if (_filter == TaskFilter.completed) {
      result = result.where((task) => task.isCompleted).toList();
    }

    if (_priorityFilter != null) {
      result =
          result.where((task) => task.priority == _priorityFilter).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((task) => task.title.toLowerCase().contains(query))
          .toList();
    }

    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.priority.index.compareTo(a.priority.index);
    });

    return result;
  }

  Future<void> _showEditTaskDialog(BuildContext context, TodoTask task) async {
    final titleController = TextEditingController(text: task.title);
    TaskPriority selectedPriority = task.priority;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Task title'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: selectedPriority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(
                          value: TaskPriority.low, child: Text('Low')),
                      DropdownMenuItem(
                          value: TaskPriority.medium, child: Text('Medium')),
                      DropdownMenuItem(
                          value: TaskPriority.high, child: Text('High')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setLocalState(() {
                        selectedPriority = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final updatedTitle = titleController.text.trim();
                    if (updatedTitle.isEmpty) {
                      return;
                    }
                    await context.read<TaskProvider>().updateTask(
                          id: task.id,
                          title: updatedTitle,
                          priority: selectedPriority,
                        );
                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = _filteredTasks(taskProvider.tasks);
        if (taskProvider.tasks.isEmpty) {
          return const Center(
              child: Text('No tasks yet. Add your first task from +.'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tasks',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SegmentedButton<TaskFilter>(
                          segments: const [
                            ButtonSegment(
                                value: TaskFilter.all, label: Text('All')),
                            ButtonSegment(
                                value: TaskFilter.active,
                                label: Text('Active')),
                            ButtonSegment(
                                value: TaskFilter.completed,
                                label: Text('Done')),
                          ],
                          selected: {_filter},
                          onSelectionChanged: (value) {
                            setState(() {
                              _filter = value.first;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Low'),
                          selected: _priorityFilter == TaskPriority.low,
                          onSelected: (_) {
                            setState(() {
                              _priorityFilter =
                                  _priorityFilter == TaskPriority.low
                                      ? null
                                      : TaskPriority.low;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          label: const Text('Medium'),
                          selected: _priorityFilter == TaskPriority.medium,
                          onSelected: (_) {
                            setState(() {
                              _priorityFilter =
                                  _priorityFilter == TaskPriority.medium
                                      ? null
                                      : TaskPriority.medium;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          label: const Text('High'),
                          selected: _priorityFilter == TaskPriority.high,
                          onSelected: (_) {
                            setState(() {
                              _priorityFilter =
                                  _priorityFilter == TaskPriority.high
                                      ? null
                                      : TaskPriority.high;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Chip(label: Text('Pending: ${taskProvider.pendingCount}')),
                  const SizedBox(width: 8),
                  Chip(label: Text('Done: ${taskProvider.completedCount}')),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: taskProvider.completedCount == 0
                        ? null
                        : () {
                            taskProvider.clearCompleted();
                          },
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Clear done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text('No tasks match your current filters.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                            onDismissed: (_) {
                              final removedTask = task;
                              taskProvider.removeTask(task.id);
                              ScaffoldMessenger.of(context)
                                ..clearSnackBars()
                                ..showSnackBar(
                                  SnackBar(
                                    content: const Text('Task deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        taskProvider.addTask(
                                          removedTask.title,
                                          removedTask.priority,
                                        );
                                      },
                                    ),
                                  ),
                                );
                            },
                            child: TaskTile(
                              task: task,
                              onChanged: (value) {
                                taskProvider.toggleTask(task.id, value);
                              },
                              onEdit: () => _showEditTaskDialog(context, task),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
