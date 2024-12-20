// widgets/NoteCard.dart
import 'package:flutter/material.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class NoteCard extends StatelessWidget {
  final String id;
  final String title;
  final String note;
  final String dateTime;
  final Color cardColor;
  final Function(String, Color) colorPicker;
  final Function(String) onDelete;
  final Function(String) onEdit;

  const NoteCard({
    super.key,
    required this.id,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.onDelete,
    required this.onEdit,
    required this.cardColor,
    required this.colorPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: InkWell(
        onTap: () => onEdit(id),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            note,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 14, color: Colors.black),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildOptionsMenu(context),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<SampleItem>(
      icon: const Icon(
        Icons.more_vert,
        size: 20,
        color: Colors.black,
      ),
      onSelected: (value) {
        switch (value) {
          case SampleItem.itemOne:
            onDelete(id);
            break;
          case SampleItem.itemTwo:
            colorPicker(id, cardColor);
            break;
          case SampleItem.itemThree:
            onEdit(id);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SampleItem.itemOne,
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8),
              Text('Delete',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
        PopupMenuItem(
          value: SampleItem.itemTwo,
          child: Row(
            children: [
              const Icon(Icons.color_lens, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Change Color',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
        PopupMenuItem(
          value: SampleItem.itemThree,
          child: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              Text('Edit',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}