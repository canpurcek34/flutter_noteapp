import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late Future<bool> _themePreferenceFuture;
  String? _formattedDate;
  bool _isDarkMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _themePreferenceFuture = _loadThemePreference();
    _initializeDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initializeDate() async {
    await initializeDateFormatting('tr_TR', null);
    setState(() {
      _formattedDate = DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());
    });
  }

  Future<bool> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('isDarkMode') ?? false);
    return _isDarkMode;
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemePreference(_isDarkMode);
    });
  }

  Future<void> _addNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/insert.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'uuid': user.uid,
          'title': _titleController.text,
          'note': _noteController.text,
          'type': 'note',
          'color': 'white',
          'date': _formattedDate ?? DateTime.now().toString(),
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['success'] == 1) {
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(responseData['message'] ?? 'An error occurred');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add note: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
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
              title: const Text('Yeni Not Ekle'),
              actions: [
                Row(
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Switch.adaptive(
                      value: _isDarkMode,
                      onChanged: (_) => _toggleTheme(),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.cyan,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
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
