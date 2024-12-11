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
  bool _isDarkMode = false;
  bool _isLoading = false;
  late Future<bool> _themePreferenceFuture;
  @override
  void initState() {
    super.initState();
    _themePreferenceFuture = _loadThemePreference();
    _initializeDateFormat();
  }

  void _initializeDateFormat() {
    initializeDateFormatting('tr_TR', null).then((_) {
      setState(() {
        _formattedDate =
            DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());
      });
    });
  }

  Future<bool> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
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

  Future<void> addList() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog("Kullanıcı oturumu yok");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/list/insert.php'),
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
        _showErrorSnackBar(responseData['message'] ?? "Bir hata oluştu");
      }
    } catch (e) {
      _showErrorSnackBar('Bağlantı hatası: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                title: const Text('Yeni Liste Ekle'),
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
                          controller: _listController,
                          decoration: const InputDecoration(
                            labelText: 'Liste',
                            hintText: 'Liste içeriğini girin',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Öğe giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    addList();
                                  }
                                },
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
        });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }
}
