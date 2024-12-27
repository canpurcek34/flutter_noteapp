// viewmodels/edit_list_viewmodel.dart
import 'package:flutter/material.dart';
import '../service/app_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'home_viewmodel.dart';


class EditListViewModel extends ChangeNotifier {
  final AppService _appService = AppService();
    bool _isLoading = false;
   bool get isLoading => _isLoading;

     Future<void> updateList(
    BuildContext context,
    String id,
    String list,
  ) async {
       _isLoading = true;
        notifyListeners();
       try {
            final now = DateTime.now();
           final formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);
           await _appService.updateList(id, list, formattedDate);
             if(context.mounted) {
                 final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
                   await homeViewModel.fetchLists();
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: const Text('Not güncellendi.'),
                  backgroundColor: Colors.green.shade600,
                   behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  ),
               );
           }
    } catch (e) {
          if(context.mounted)
            {
             _showErrorSnackBar(context, 'Bir hata oluştu: $e');
            }
    } finally {
      _isLoading = false;
         notifyListeners();
    }
  }

    void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
         behavior: SnackBarBehavior.floating,
      ),
    );
  }
}