import 'package:flutter/material.dart';

enum SampleItem { itemOne, itemTwo }

class ListCard extends StatelessWidget {
  final String id; // Not ID'si
  final String listItem;
  final Color cardColor;
  final Function(String) onEdit;
  final Function(String, Color) colorPicker;
  final Function(String) onDelete; // Silme işlemi için callback
  final Function(String, bool)
      onCheckboxChanged; // Checkbox durumu değiştiğinde çağrılır
  final bool isChecked; // Checkbox durumu

  const ListCard({
    required this.id,
    required this.listItem,
    required this.onDelete,
    required this.onCheckboxChanged,
    required this.isChecked,
    required this.cardColor,
    super.key,
    required this.onEdit, required this.colorPicker,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onEdit(id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(
              color: Colors.grey
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              /*BoxShadow(
                color:
                Colors.grey.withOpacity(0.5), // Gölgenin rengi ve opaklığı
                spreadRadius: 1, // Gölgenin yayılma miktarı
                blurRadius: 5, // Gölgenin bulanıklık derecesi
                offset: const Offset(0, 3), // Gölgenin konumu (x, y)
              ),*/
            ]),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  if (value != null) {
                    onCheckboxChanged(id, value); // Durumu üst widget'a bildir
                  }
                },
              ),
              const SizedBox(width: 8), // Checkbox ile metin arasında boşluk
              Expanded(
                child: Text(
                  listItem,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  if (value == SampleItem.itemOne) {
                    onDelete(id); // Silme işlemi için callback
                  } else if (value == SampleItem.itemTwo) {
                    colorPicker(id, cardColor); // Renk seçimi için callback
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SampleItem>>[
                  const PopupMenuItem<SampleItem>(
                    value: SampleItem.itemOne,
                    child: Text('Delete'),
                  ),
                  const PopupMenuItem<SampleItem>(
                    value: SampleItem.itemTwo,
                    child: Text('Renk Seç'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
