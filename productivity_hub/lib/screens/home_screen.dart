import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_task.dart';
import '../providers/note_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import 'notes_view.dart';
import 'tasks_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<DateTime?> _pickDueDate(
      BuildContext context, DateTime? initial) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    return pickedDate;
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '$month/$day/${localDate.year}';
  }

  String get _todayLabel {
    final now = DateTime.now();
    final weekday = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][now.weekday - 1];
    return '$weekday, ${now.day}/${now.month}/${now.year}';
  }

  Future<void> _openCreateChooser() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create new',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('New Task'),
                  subtitle: const Text('Track your next action item'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddTaskDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_add_outlined),
                  title: const Text('New Note'),
                  subtitle: const Text('Capture ideas and details quickly'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddNoteDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDueDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Create Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: 'Task title'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(
                          value: TaskPriority.low,
                          child: Text('Low'),
                        ),
                        DropdownMenuItem(
                          value: TaskPriority.medium,
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: TaskPriority.high,
                          child: Text('High'),
                        ),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDueDate == null
                                ? 'No due date'
                                : 'Due: ${_formatDate(selectedDueDate!)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate =
                                await _pickDueDate(context, selectedDueDate);
                            if (pickedDate == null) {
                              return;
                            }
                            setLocalState(() {
                              selectedDueDate = pickedDate;
                            });
                          },
                          child: const Text('Pick date'),
                        ),
                        if (selectedDueDate != null)
                          IconButton(
                            onPressed: () {
                              setLocalState(() {
                                selectedDueDate = null;
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Clear due date',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      return;
                    }
                    final taskProvider = context.read<TaskProvider>();
                    await taskProvider.addTask(
                      title,
                      selectedPriority,
                      dueDate: selectedDueDate,
                    );
                    if (dialogContext.mounted) {
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

  Future<void> _showAddNoteDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  minLines: 3,
                  maxLines: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  return;
                }
                final noteProvider = context.read<NoteProvider>();
                await noteProvider.addNote(
                  title: title,
                  content: content,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const TasksView(),
      const NotesView(),
    ];

    final titles = ['Tasks', 'Notes'];
    final subtitles = [
      'Plan your day productively',
      'Collect your ideas and thoughts'
    ];

    final taskProvider = context.watch<TaskProvider>();
    final noteProvider = context.watch<NoteProvider>();
    final completionPercent = (taskProvider.completionRatio * 100).round();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productivity Hub',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(_todayLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return IconButton(
                onPressed: settingsProvider.toggleThemeMode,
                tooltip: settingsProvider.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                icon: Icon(settingsProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_currentIndex == 0
                      ? Icons.checklist
                      : Icons.sticky_note_2_rounded),
                ),
                title: Text(titles[_currentIndex],
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subtitles[_currentIndex]),
                    const SizedBox(height: 6),
                    if (_currentIndex == 0) ...[
                      LinearProgressIndicator(
                        value: taskProvider.completionRatio,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completionPercent% complete • ${taskProvider.overdueCount} overdue',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else ...[
                      Text(
                        '${noteProvider.totalNotes} notes • ${noteProvider.pinnedCount} pinned',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateChooser,
        icon: const Icon(Icons.add),
        label: Text(_currentIndex == 0 ? 'Add task' : 'Add note'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_outlined),
            selectedIcon: Icon(Icons.sticky_note_2_rounded),
            label: 'Notes',
          ),
        ],
      ),
    );
  }
}
