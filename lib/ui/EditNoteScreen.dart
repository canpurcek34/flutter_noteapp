import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/error_utils.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  bool _isLoading = false;

   final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title'] ?? '');
    _noteController = TextEditingController(text: widget.note['note'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
      if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);
      final response = await http.post(
       Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/note/update.php'),
       headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
       body: jsonEncode({
         'id': widget.note['id'].toString(),
         'title': _titleController.text,
        'note': _noteController.text,
        'date': formattedDate
       }),
      );

      final data = json.decode(response.body);

      if (data['success'] == 1) {
         if (mounted) {
          Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Not güncellendi.'),
               backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
             ),
           );
         }
      } else {
        if (mounted){
            ErrorUtils.showErrorSnackBar(context, 'Hata: ${data['message']}');
        }
      }
    } catch (e) {
       if(mounted){
         ErrorUtils.showErrorSnackBar(context, 'Bir hata oluştu: $e');
       }
    } finally {
      if (mounted) {
           setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context);

   return  Scaffold(
        appBar: AppBar(
          title: const Text('Düzenle'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode),
             onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
            ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
               key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                 ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Başlık giriniz' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                   decoration: const InputDecoration(
                       alignLabelWithHint: true,
                      ),
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                       validator: (value) =>
                        value?.isEmpty ?? true ? 'Not giriniz' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateNote,
                     style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                          strokeWidth: 2,
                             valueColor: AlwaysStoppedAnimation<Color>(
                           Colors.white),
                         ),
                        )
                       : const Text(
                          'Kaydet',
                         style: TextStyle(fontSize: 16),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
