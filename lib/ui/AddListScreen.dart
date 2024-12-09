import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddListScreen extends StatefulWidget {
  const AddListScreen({super.key});

  @override
  _AddListScreenState createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listController = TextEditingController();
  String? _formattedDate;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _initializeDateFormat();
  }

  void _initializeDateFormat() {
    initializeDateFormatting('tr_TR', null).then((_) {
      setState(() {
        _formattedDate = DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());
      });
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveThemePreference(isDarkMode);
    });
  }

  Future<void> addList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog("Kullanıcı oturumu yok");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/list/insert.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'uuid': user.uid,
          'list': _listController.text,
          'color': "white",
          'isChecked': "0",
          'type': "list",
          'date': _formattedDate ?? DateTime.now().toString(),
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == 1) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liste başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog(responseData['message'] ?? 'Bir hata oluştu');
      }
    } catch (e) {
      _showErrorDialog('Bağlantı hatası: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode 
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.cyan,
              secondary: Colors.cyanAccent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.cyan.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.cyan.shade400, width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan,
              secondary: Colors.cyanAccent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.cyan.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.cyan.shade400, width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Liste Ekle'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Row(
              children: [
                Text(
                  'Dark Mode', 
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (_) => _toggleTheme(),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.cyan,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _listController,
                  decoration: InputDecoration(
                    labelText: 'Liste',
                    prefixIcon: const Icon(Icons.list),
                    hintText: 'Liste içeriğini girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Öğe giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      addList();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
    _listController.dispose();
    super.dispose();
  }
}