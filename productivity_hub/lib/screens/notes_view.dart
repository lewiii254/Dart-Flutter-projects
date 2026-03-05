import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showPinnedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    var result = notes.toList();

    if (_showPinnedOnly) {
      result = result.where((note) => note.isPinned).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      result.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.timestamp.compareTo(a.timestamp);
      });
      return result;
    }

    result = result.where((note) {
      final haystack = '${note.title} ${note.content}'.toLowerCase();
      return haystack.contains(query);
    }).toList();

    result.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.timestamp.compareTo(a.timestamp);
    });
    return result;
  }

  Future<void> _openNoteEditor(BuildContext context, Note note) async {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                minLines: 4,
                maxLines: 8,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await context.read<NoteProvider>().togglePin(note.id);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: Icon(
                      note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                    ),
                    label: Text(note.isPinned ? 'Unpin' : 'Pin'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await context.read<NoteProvider>().removeNote(note.id);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) {
                        return;
                      }
                      await context.read<NoteProvider>().updateNote(
                            id: note.id,
                            title: title,
                            content: content,
                          );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    child: const Text('Save changes'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        final notes = _filterNotes(noteProvider.notes);
        if (notes.isEmpty) {
          return Center(
            child: Text(
              noteProvider.totalNotes == 0
                  ? 'No notes yet. Capture your first idea from +.'
                  : 'No notes match your search.',
            ),
          );
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
                      hintText: 'Search notes',
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
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Pinned only'),
                        selected: _showPinnedOnly,
                        onSelected: (_) {
                          setState(() {
                            _showPinnedOnly = !_showPinnedOnly;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Chip(label: Text('Pinned: ${noteProvider.pinnedCount}')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteCard(
                    note: note,
                    onTap: () => _openNoteEditor(context, note),
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
