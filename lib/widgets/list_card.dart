import 'package:flutter/material.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class ListCard extends StatelessWidget {
  final String id;
  final String listItem;
  final Color cardColor;
  final Function(String) onEdit;
  final Function(String, Color) colorPicker;
  final Function(String) onDelete;
  final Function(String, bool) onCheckboxChanged;
  final bool isChecked;

  const ListCard({
    super.key,
    required this.id,
    required this.listItem,
    required this.onDelete,
    required this.onCheckboxChanged,
    required this.isChecked,
    required this.cardColor,
    required this.onEdit,
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => onEdit(id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _buildCheckbox(context),
              const SizedBox(width: 8),
              _buildListItemText(context),
              _buildOptionsMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: Colors.black, // checkbox color
      ), // Your color,
      child: Checkbox(
        value: isChecked,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        checkColor: Colors.black, // Check mark will always be black
        fillColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // White background when checked
          }
          return Colors.transparent; // Transparent when unchecked
        }),
        onChanged: (bool? value) {
          if (value != null) {
            onCheckboxChanged(id, value);
          }
        },
      ),
    );
  }

  Widget _buildListItemText(BuildContext context) {
    return Expanded(
      child: Text(
        listItem,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: isChecked ? TextDecoration.lineThrough : null,
            color: Colors.black,
            fontSize: 16
            ),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<SampleItem>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.black),
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
              Text('Sil',
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
              Text('Rengi Değiştir',
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
              Text('Düzenle',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}