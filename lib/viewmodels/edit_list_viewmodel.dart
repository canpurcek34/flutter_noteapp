// viewmodels/edit_list_viewmodel.dart
import 'package:flutter/material.dart';
import '../service/app_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'home_viewmodel.dart';

class EditListViewModel extends ChangeNotifier {
  final AppService _appService = AppService();
  bool _isLoading = false;
  bool _hasError = false;

  static final DateFormat _dateFormatter = DateFormat('d MMMM y HH:mm', 'tr_TR');

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

  Future<bool> updateList(BuildContext context, String id, String list) async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _clearError();

    try {
      final formattedDate = _dateFormatter.format(DateTime.now());
      await _appService.updateList(id, list, formattedDate);
      
      if (!context.mounted) return false;
      
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      await homeViewModel.fetchLists();
      
      Navigator.pop(context, true);
      _showSuccessMessage(context);
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      _showErrorSnackBar(context, 'Bir hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Liste güncellendi.'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
}