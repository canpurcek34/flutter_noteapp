import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // DateFormat için

class AddListScreen extends StatefulWidget {
  @override
  _AddListScreenState createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final _formKey = GlobalKey<FormState>();
  String _list = '';
  String? _formattedDate; // Formatlanmış tarih
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    // Tarih formatını başlatıyoruz ve ardından formatlı tarihi alıyoruz
    initializeDateFormatting('tr_TR', null).then((_) {
      setState(() {
        DateTime now = DateTime.now();
        _formattedDate = DateFormat.yMMMMd('tr_TR').add_jm().format(now);
      });
    });
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

  Future<void> addList() async {
    final user =
        FirebaseAuth.instance.currentUser; // Firebase'den kullanıcı bilgisi al
    if (user == null) {
      throw Exception("Kullanıcı oturumu yok");
    }
    final uid = user.uid; // UUID'yi al
    const type = "list";

    final response = await http.post(
      Uri.parse(
          'https://emrecanpurcek.com.tr/projects/methods/list/insert.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uuid': uid,
        'list': _list,
        'color': "white",
        'isChecked': "0",
        'type': type,
        'date': _formattedDate ??
            DateTime.now().toString(), // Formatlanmış tarihi gönderiyoruz
      }),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['success'] == 1) {
      Navigator.pop(
          context, true); // Başarılı olursa geri dön ve listeyi yenile
      print("Yeni veri girişi başarılı.");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['message'] ?? 'Bir hata oluştu'),
          behavior: SnackBarBehavior.floating));
      print("Yeni veri girişi başarısız.");
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
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.cyan,
            ),
          ),
      child:
        Scaffold(
          appBar: AppBar(
            title: Text('Yeni Liste Ekle'),
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
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Gölgenin konumu
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Liste',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Öğe giriniz';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _list = value!;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        addList();
                      }
                    },
                    child: Text('Kaydet'),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
