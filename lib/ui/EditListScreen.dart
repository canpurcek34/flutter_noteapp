import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditListScreen extends StatefulWidget {
  final Map<String, dynamic> list;

  const EditListScreen({super.key, required this.list});

  @override
  _EditListScreenState createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  final _listController = TextEditingController();
  late String _date;
  String? formattedDate;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _listController.text = widget.list['list'] ?? '';
    _date = widget.list['date'] ?? '';
  }
    // Theme preference yükleme metodu
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
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
      isDarkMode = !isDarkMode;
      _saveThemePreference(isDarkMode);
    });
  }

  Future<void> updateList() async {
    await initializeDateFormatting('tr_TR', null);
    final now = DateTime.now();
    formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);

    final response = await http.post(
      Uri.parse(
          'https://emrecanpurcek.com.tr/projects/methods/list/update.php'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'id': widget.list['id'].toString(),
        'list': _listController.text,
        'date': formattedDate ?? now.toString()
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.cyan,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.cyan,
            ),
          ),
      child: 
        Scaffold(
          appBar: AppBar(
            title: const Text('Düzenle'),
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
          ]
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
                        controller: _listController,
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
                                const TextStyle(fontSize: 12, color: Colors.black),
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
                      updateList();
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
