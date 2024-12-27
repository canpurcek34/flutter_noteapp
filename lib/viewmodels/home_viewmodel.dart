//viewmodels/home_viewmodel.dart
import 'package:flutter/material.dart';
import '../service/app_service.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends ChangeNotifier {
  final AppService _appService = AppService();
  bool _isLoading = false;
  bool _hasError = false;

  static final Map<String, Color> colorNames = {
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

  static final DateFormat _primaryFormatter = DateFormat('d MMMM y HH:mm', 'tr_TR');
  static final DateFormat _fallbackFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  List<dynamic> _notes = [];
  List<dynamic> _lists = [];

  List<dynamic> get notes => List.unmodifiable(_notes);
  List<dynamic> get lists => List.unmodifiable(_lists);

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = '';
      notifyListeners();
    }
  }

  Future<void> fetchNotes() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final fetchedNotes = await _appService.fetchNotes();
      _notes = fetchedNotes..sort((a, b) => _parseDate(b['date']).compareTo(_parseDate(a['date'])));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLists() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final fetchedLists = await _appService.fetchLists();
      _processListColors(fetchedLists);
      _lists = fetchedLists..sort((a, b) => _parseDate(b['date']).compareTo(_parseDate(a['date'])));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _processListColors(List<dynamic> lists) {
    for (var item in lists) {
      String colorName = item['color'] ?? 'white';
      item['flutterColor'] = colorNames[colorName] ?? Colors.white;
    }
  }

  Future<bool> updateCheckbox(String id, bool value) async {
    _clearError();
    try {
      await _appService.updateCheckbox(id, value);
      await fetchLists();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    _clearError();
    try {
      await _appService.deleteNote(id);
      _notes.removeWhere((note) => note['id'].toString() == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteList(String id) async {
    _clearError();
    try {
      await _appService.deleteList(id);
      _lists.removeWhere((list) => list['id'].toString() == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      return _primaryFormatter.parse(dateString);
    } catch (e) {
      return _fallbackFormatter.parse(dateString);
    }
  }
}