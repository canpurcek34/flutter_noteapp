import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late String _date;
  String? formattedDate;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note['title'] ?? '';
    _noteController.text = widget.note['note'] ?? '';
    _date = widget.note['date'] ?? '';
  }

  Future<void> updateNote() async {
    await initializeDateFormatting('tr_TR', null);
    final now = DateTime.now();
    formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);

    final response = await http.post(
      Uri.parse(
          'https://emrecanpurcek.com.tr/projects/methods/note/update.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': widget.note['id'].toString(),
        'title': _titleController.text,
        'note': _noteController.text,
        'date': formattedDate ?? now.toString(),
      }),
    );

    final data = json.decode(response.body);

    if (data['success'] == 1) {
      // Güncelleme başarılı, NotebookScreen'e geri dönüyoruz
      Navigator.pop(context, true);

      // Snackbar ile mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not güncellendi.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Güncelleme başarısız, kullanıcıya hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${data['message']}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Düzenle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    minLines: 1,
                    maxLines: null,
                    expands: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0, // Aralık
                runSpacing: 4.0, // Satır arası aralık
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Text(
                        'Düzenlenme Zamanı: $_date',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  updateNote();
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
