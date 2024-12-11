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
    Key? key,
    required this.id,
    required this.listItem,
    required this.onDelete,
    required this.onCheckboxChanged,
    required this.isChecked,
    required this.cardColor,
    required this.onEdit,
    required this.colorPicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      elevation: 2, // Hafif gölgelendirme
      child: InkWell(
        onTap: () => onEdit(id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _buildCheckbox(),
              const SizedBox(width: 8),
              _buildListItemText(),
              _buildOptionsMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Checkbox(
      value: isChecked,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      onChanged: (bool? value) {
        if (value != null) {
          onCheckboxChanged(id, value);
        }
      },
    );
  }

  Widget _buildListItemText() {
    return Expanded(
      child: Text(
        listItem,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isChecked ? Colors.black : Colors.black, //renk değişim düzenlemeleri yapılabilir
          fontSize: 16,
          decoration: isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }

  Widget _buildOptionsMenu() {
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
        const PopupMenuItem(
          value: SampleItem.itemOne,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Sil'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: SampleItem.itemTwo,
          child: Row(
            children: [
              Icon(Icons.color_lens, color: Colors.blue),
              SizedBox(width: 8),
              Text('Rengi Değiştir'),
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
        ),
      ],
    );
  }
}
