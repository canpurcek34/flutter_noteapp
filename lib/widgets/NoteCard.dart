import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class NoteCard extends StatelessWidget {
  final String id; // Not ID'si
  final String title;
  final String note;
  final String dateTime;
  final Color cardColor;
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onEdit(id); // Kart tıklanırsa düzenleme callback'ini çağır
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.grey.withOpacity(0.5), // Gölgenin rengi ve opaklığı
                spreadRadius: 1, // Gölgenin yayılma miktarı
                blurRadius: 5, // Gölgenin bulanıklık derecesi
                offset: const Offset(0, 3), // Gölgenin konumu (x, y)
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == SampleItem.itemOne) {
                        onDelete(id); // Silme işlemi için callback
                      } else if (value == SampleItem.itemTwo) {
                        _showColorPicker(context); // Renk seçimi başlatılıyor
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
              Row(
                children: [
                  Flexible(
                    child: Text(
                      note,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dateTime,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Uzun metin kısaltılır
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color selectedColor = cardColor; // Varsayılan olarak mevcut kart rengi

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bir renk seçin'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color; // Seçilen renk güncelleniyor
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog kapatılıyor
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                //onColorChange(id, selectedColor); // Renk değiştirme callback'i
                Navigator.of(context).pop(); // Diyalog kapatılıyor
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
