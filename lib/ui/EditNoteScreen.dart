import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const EditNoteScreen({super.key, required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late String _date;
  String? formattedDate;
  bool _isDarkMode = false;
  bool _isLoading = false;
  String selectedMode = "Açık Mod";


  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note['title'] ?? '';
    _noteController.text = widget.note['note'] ?? '';
    _date = widget.note['date'] ?? '';
    _loadThemePreference();
  }
    // Theme preference yükleme metodu
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      selectedMode = _isDarkMode ? "Açık Mod" : "Koyu Mod";
    });
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
        const SnackBar(
          content: Text('Not güncellendi.'),
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
    final colorScheme = _getColorScheme(_isDarkMode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // TextField için stil
          filled: true,
          fillColor: colorScheme.surface,
          labelStyle: TextStyle(color: colorScheme.primary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Düzenle'),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min, // Gereksiz boşluğu önler
              children: [
                Text(
                  selectedMode,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch.adaptive(
                  // Platformlara duyarlı switch
                  value: _isDarkMode,
                  onChanged: (_) => _toggleTheme(),
                  activeColor: Colors.cyan,
                ),
              ],
            ),
            const SizedBox(width: 8), // Daha ince boşluk
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                   elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _titleController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                )),
                const SizedBox(height: 16),
                Card(
                   elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                )),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Düzenlenme Zamanı: $_date',
                      style: TextStyle(
                        fontSize: 14, 
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : updateNote,
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
