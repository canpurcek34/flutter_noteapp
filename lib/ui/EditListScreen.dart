import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditListScreen extends StatefulWidget {
  final Map<String, dynamic> list;

  const EditListScreen({Key? key, required this.list}) : super(key: key);

  @override
  _EditListScreenState createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  late final TextEditingController _listController;
  late final String _originalDate;
  bool _isDarkMode = false;
  bool _isLoading = false;
  String selectedMode = "Açık Mod";


  @override
  void initState() {
    super.initState();
    _listController = TextEditingController(text: widget.list['list'] ?? '');
    _originalDate = widget.list['date'] ?? '';
    _loadThemePreference();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
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

  Future<void> _updateList() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await initializeDateFormatting('tr_TR', null);
      final now = DateTime.now();
      final formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);

      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/list/update.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': widget.list['id'].toString(),
          'list': _listController.text,
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
              children: [
                Text(
                  selectedMode, 
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                Switch(
                  value: _isDarkMode,
                  onChanged: (_) => _toggleTheme(),
                  activeColor: colorScheme.secondary,
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return colorScheme.secondary.withOpacity(0.5);
                    }
                    return Colors.grey.shade500;
                  }),
                ),
              ],
            ),
            const SizedBox(width: 10),
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
                    controller: _listController,
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
                      'Düzenlenme Zamanı: $_originalDate',
                      style: TextStyle(
                        fontSize: 14, 
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateList,
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