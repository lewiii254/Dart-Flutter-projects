import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_task.dart';
import '../providers/note_provider.dart';
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
                    await taskProvider.addTask(title, selectedPriority);
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
                subtitle: Text(subtitles[_currentIndex]),
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
