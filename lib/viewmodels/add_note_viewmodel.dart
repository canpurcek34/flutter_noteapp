// viewmodels/add_note_viewmodel.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/app_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'home_viewmodel.dart';

class AddNoteViewModel extends ChangeNotifier {
  final AppService _appService = AppService();
  bool _isLoading = false;
  bool _hasError = false;

  static final DateFormat _dateFormatter = DateFormat.yMMMMd('tr_TR').add_jm();

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String get _formattedDate => _dateFormatter.format(DateTime.now());

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

  Future<bool> addNote(BuildContext context, String title, String note) async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _clearError();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog(context, "Kullanıcı oturumu yok");
      _setLoading(false);
      return false;
    }

    try {
      await _appService.addNote(user.uid, title, note, _formattedDate);
      
      if (!context.mounted) return false;
      
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      await homeViewModel.fetchNotes();
      
      Navigator.pop(context, true);
      _showSuccessMessage(context);
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      _showErrorSnackBar(context, 'Bağlantı hatası: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not başarıyla eklendi'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
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
}