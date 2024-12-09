import 'package:flutter/material.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class NoteCard extends StatelessWidget {
  final String id; // Not ID'si
  final String title;
  final String note;
  final String dateTime;
  final Color cardColor;
  final Function(String, Color) colorPicker;
  final Function(String) onDelete; // Silme işlemi için callback
  final Function(String) onEdit; // Düzenleme işlemi için callback
  //final Function(String, Color) onColorChange; // Renk değiştirme callback

  const NoteCard({
    required this.id,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.onDelete, // Silme işlemi için callback'i al
    required this.onEdit, // Düzenleme işlemi için callback'i al
    //required this.onColorChange, // Renk değiştirme callback'i al
    required this.cardColor,
    super.key, required this.colorPicker,
  });

 
  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      elevation: 2, // Hafif bir gölgelendirme
      child: InkWell(
        onTap: () => onEdit(id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildNoteContent(),
              const SizedBox(height: 4),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildOptionsMenu(),
      ],
    );
  }

  Widget _buildNoteContent() {
    return Text(
      note,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black),
      maxLines: 3, // Maks 3 satır
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Text(
      dateTime,
      style: TextStyle(
        color: Colors.black.withOpacity(0.6),
        fontSize: 12,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<SampleItem>(
      icon: const Icon(Icons.more_vert, size: 20),
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
        const PopupMenuItem(
          value: SampleItem.itemOne,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SampleItem.itemTwo,
          child: Row(
            children: [
              Icon(Icons.color_lens, color: Colors.blue),
              SizedBox(width: 8),
              Text('Change Color'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SampleItem.itemThree,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black),
              SizedBox(width: 8),
              Text('Düzenle'),
            ],
          ),
        )
      ],
    );
  }
}
