import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/NoteCard.dart';


class NotesTab extends StatelessWidget {
  
  static final Map<String, Color> colorNames = {
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

  final List<dynamic> notes;
  final Function(String id) onDelete;
  final Function(String id) onEdit;
  final int crossCount;
  final Function(String id, Color color) onColorChanged;

  const NotesTab({
      super.key,
      required this.notes,
      required this.onDelete,
      required this.onEdit,
      required this.crossCount,
    required this.onColorChanged,
  });


  @override
  Widget build(BuildContext context) {
    int noteCrossCount = crossCount;
    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: noteCrossCount,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
         final note = notes[index];
        final Color cardColor =  colorNames[note['color']?.toLowerCase()] ?? Colors.transparent;
        return NoteCard(
          id: note['id'].toString(),
          title: note['title'],
          note: note['note'],
          dateTime: note['date'],
          onDelete: onDelete,
          onEdit: onEdit,
           cardColor: cardColor,
            colorPicker: onColorChanged,
        );
      },
    );
  }
}
