import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/NoteCard.dart';

class NotesTab extends StatelessWidget {
  final List<dynamic> notes;
  final Function(String id) onDelete;
  final Function(String id) onEdit;
  final int crossCount;

  NotesTab(
      {super.key,
      required this.notes,
      required this.onDelete,
      required this.onEdit,
      required this.crossCount});

  Map<String, Color> colorNames = {
    "red": Colors.red,
    "blue": Colors.blue,
    "green": Colors.green,
    "yellow": Colors.yellow,
    "black": Colors.black,
    "white": Colors.white,
    "orange": Colors.orange,
    "grey": Colors.grey,
    "purple": Colors.purple,
    "cyan": Colors.cyan,
  };

  Color parseColorByName(String colorName) {
    return colorNames[colorName.toLowerCase()] ??
        Colors.transparent; // Bulamazsa şeffaf döner
  }

  @override
  Widget build(BuildContext context) {
    int cross = crossCount;

    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        Color color = parseColorByName(note['color']);
        return NoteCard(
          id: note['id'].toString(),
          title: note['title'],
          note: note['note'],
          dateTime: note['date'],
          onDelete: onDelete,
          onEdit: onEdit,
          cardColor: color,
        );
      },
    );
  }
}
