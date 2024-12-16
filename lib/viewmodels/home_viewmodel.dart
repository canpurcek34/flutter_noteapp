//viewmodels/home_viewmodel.dart
import 'package:flutter/material.dart';
import '../service/AppService.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends ChangeNotifier {
  final AppService _appService = AppService();
  bool _isLoading = false;

  List<dynamic> _notes = [];
  List<dynamic> _lists = [];

  List<dynamic> get notes => _notes;
  List<dynamic> get lists => _lists;

  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedNotes = await _appService.fetchNotes();
       _notes = fetchedNotes..sort((a, b) {
           final DateTime dateA = _parseDate(a['date']);
          final DateTime dateB = _parseDate(b['date']);
         return dateB.compareTo(dateA);
       });
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLists() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedLists = await _appService.fetchLists();
       Map<String, Color> colorNames = {
        "red": Colors.red,
        "blue": Colors.blue,
        "green": Colors.green,
        "yellow": Colors.yellow,
        "orange": Colors.orange,
        "grey": Colors.grey,
        "purple": Colors.purple,
        "cyan": Colors.cyan,
        "white": Colors.white
      };

      for (var _colors in fetchedLists) {
        String colorName = _colors['color'] ?? 'white';
        _colors['flutterColor'] = colorNames[colorName] ?? Colors.white;
      }
        _lists = fetchedLists..sort((a, b) {
          final DateTime dateA = _parseDate(a['date']);
           final DateTime dateB = _parseDate(b['date']);
         return dateB.compareTo(dateA);
       });
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

   DateTime _parseDate(String dateString) {
    try {
        final formatter = DateFormat('d MMMM y HH:mm', 'tr_TR');
        return formatter.parse(dateString);
     } catch (e) {
         final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        return formatter.parse(dateString);
     }
    }

  Future<void> updateCheckbox(String id, bool value) async {
    try {
      await _appService.updateCheckbox(id, value);
      fetchLists();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _appService.deleteNote(id);
      fetchNotes();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await _appService.deleteList(id);
      fetchLists();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
}