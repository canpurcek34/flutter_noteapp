import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // DateFormat için

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _note = '';
  String? _formattedDate; // Formatlanmış tarih

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

  Future<void> addNote() async {
    final user =
        FirebaseAuth.instance.currentUser; // Firebase'den kullanıcı bilgisi al
    if (user == null) {
      throw Exception("Kullanıcı oturumu yok");
    }
    final uid = user.uid; // UUID'yi al
    const type = "note";

    final response = await http.post(
      Uri.parse(
          'https://emrecanpurcek.com.tr/projects/methods/note/insert.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uuid': uid,
        'title': _title,
        'note': _note,
        'type': type,
        'color': "white",
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Not Ekle'),
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
                      labelText: 'Başlık',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Başlık giriniz';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _title = value!;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Not',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Not giriniz';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _note = value!;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    addNote();
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
