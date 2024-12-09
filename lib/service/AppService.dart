
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class AppService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Hata mesajı döndüren yardımcı bir metod
  String _handleError(dynamic error) {
    return error.toString();
  }

  String? formattedDate;

  /// Kullanıcı doğrulamasını kontrol eden yardımcı bir metod
  User? _getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu yok");
    return user;
  }

  /// Notları çekmek için kullanılan metod (Sunucudan HTTP ile)
  Future<List<dynamic>> fetchNotes() async {
    try {
      final user = _getCurrentUser();
      final uid = user!.uid;
      const type = "note";

      // API çağrısını yap
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/get.php'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'uuid': uid, 'type': type}), // UUID ve Type gönderiliyor
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          return data['data'];
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('HTTP Hata Kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Notları çekmek için kullanılan metod (Firebase Firestore ile)
  Future<List<dynamic>> fetchLists() async {
    try {
      final user = _getCurrentUser();
      final uid = user!.uid;
      const type = "list";

      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/list/get.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uuid': uid, 'type': type}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          return data['data'];
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('HTTP Hata Kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateCheckbox(String id, bool value) async {
    await initializeDateFormatting('tr_TR', null);
    final now = DateTime.now();
    formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);

    final isChecked = value ? 1 : 0;

    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/list/check.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          'date': formattedDate ?? now.toString(),
          'isChecked': isChecked,
        }),
      );

      final data = json.decode(response.body);
      if (data['success'] != 1) {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Sunucudan not silme işlemi
  Future<void> deleteNote(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/note/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final data = json.decode(response.body);
      if (data['success'] != 1) {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Firebase Firestore'dan bir not silme işlemi
  Future<void> deleteList(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/list/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final data = json.decode(response.body);
      if (data['success'] != 1) {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }
}

class ColorService {
  static final Map<String, Color> colorNames = {
    "red": Colors.red,
    "blue": Colors.blue,
    "green": Colors.green,
    "yellow": Colors.yellow,
    "black": Colors.black,
    "white": Colors.white,
    "orange": Colors.orange,
    "grey": Colors.grey,
    "purple": Colors.purple,
    "cyan": Colors.cyan,
  };

  static Color parseColorByName(String? colorName) {
    if (colorName == null) return Colors.white;
    return colorNames[colorName.toLowerCase()] ?? Colors.white;
  }

  static String convertColorToString(Color color) {
    return colorNames.entries
        .firstWhere((entry) => entry.value == color,
        orElse: () => const MapEntry('white', Colors.white))
        .key;
  }

  static Future<bool> updateColor(
      String id,
      Color selectedColor,
      {String apiUrl = 'https://emrecanpurcek.com.tr/projects/methods/list/color.php'}
      ) async {
    try {
      await initializeDateFormatting('tr_TR', null);
      final now = DateTime.now();
      final formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);

      final colorString = convertColorToString(selectedColor);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          'date': formattedDate,
          'color': colorString,
        }),
      );

      final data = json.decode(response.body);
      return data['success'] == 1;
    } catch (e) {
      print('Color update error: $e');
      return false;
    }
  }
}
