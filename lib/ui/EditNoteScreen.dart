import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  bool _isDarkMode = false;
  bool _isLoading = false;
  String selectedMode = "Açık Mod";
  late Future<bool> _themePreferenceFuture;
  final _formKey = GlobalKey<FormState>();



  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title'] ?? '');
    _noteController = TextEditingController(text: widget.note['note'] ?? '');
    _themePreferenceFuture = _loadThemePreference();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Theme preference yükleme metodu
  Future<bool> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('isDarkMode') ?? false);
    return _isDarkMode;
  }

  // Theme preference kaydetme metodu
  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Theme değiştirme metodu
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemePreference(_isDarkMode);
      selectedMode = _isDarkMode ? "Açık Mod" : "Koyu Mod";
    });
  }

  Future<void> updateNote() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await initializeDateFormatting('tr_TR', null);

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
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not güncellendi.'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${data['message']}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Material Design Color Palette
  ColorScheme _getColorScheme(bool isDarkMode) {
    return isDarkMode
        ? ColorScheme.dark(
            primary: Colors.cyan.shade300,
            secondary: Colors.cyanAccent.shade200,
            surface: Colors.grey.shade800,
            background: Colors.grey.shade900,
          )
        : ColorScheme.light(
            primary: Colors.cyan,
            secondary: Colors.cyanAccent,
            surface: Colors.white,
            background: Colors.white,
          );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _themePreferenceFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        return Theme(
          data: _isDarkMode
              ? ThemeData.dark().copyWith(
                  primaryColor: Colors.cyan,
                  scaffoldBackgroundColor: Colors.grey[900],
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.grey[850],
                    elevation: 0,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              : ThemeData.light().copyWith(
                  primaryColor: Colors.cyan,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.cyan,
                    elevation: 0,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Düzenle'),
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
                          //labelText: 'Başlık',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Başlık giriniz' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          //labelText: 'Not',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                        textInputAction: TextInputAction.newline,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Not giriniz' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : updateNote,
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
          ),
        );
      },
    );
  }
}
