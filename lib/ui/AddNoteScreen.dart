import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/error_utils.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
   String get _formattedDate => DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());

  Future<void> _addNote() async {
      if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ErrorUtils.showErrorDialog(context, "Kullanıcı oturumu yok");
      setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/insert.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'uuid': user.uid,
          'title': _titleController.text,
          'note': _noteController.text,
          'type': 'note',
          'color': 'white',
          'date': _formattedDate,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['success'] == 1) {
         if (mounted) {
          Navigator.pop(context, true);
         }
      } else {
        if (mounted){
      ErrorUtils.showErrorSnackBar(context, responseData['message'] ?? 'An error occurred');
       }
      }
    } catch (e) {
        if (mounted) {
         ErrorUtils.showErrorSnackBar(context, 'Failed to add note: ${e.toString()}');
        }
    } finally {
        if(mounted) {
           setState(() => _isLoading = false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);


    return Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Not Ekle'),
         actions: [
            IconButton(
              icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
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
                       labelText: 'Başlık',
                       hintText: 'Not başlığını giriniz',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Başlık giriniz' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Not',
                       hintText: 'Notunuzu giriniz',
                       alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Not giriniz' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addNote,
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

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
