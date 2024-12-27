// viewmodels/add_list_viewmodel.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/app_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'home_viewmodel.dart';


class AddListViewModel extends ChangeNotifier {
    final AppService _appService = AppService();
     bool _isLoading = false;

      bool get isLoading => _isLoading;
   String get _formattedDate =>
      DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());

    Future<void> addList(
      BuildContext context,
    String list,
  ) async {
       _isLoading = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        _showErrorDialog(context, "Kullanıcı oturumu yok");
      _isLoading = false;
      notifyListeners();
      return;
    }
         try {
         await _appService.addList(user.uid, list, _formattedDate);
             if(context.mounted) {
          final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
          await homeViewModel.fetchLists();
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Liste başarıyla eklendi'),
               backgroundColor: Colors.green,
              ),
             );
           }
     } catch (e) {
          if(context.mounted)
         {
          _showErrorSnackBar(context,'Bağlantı hatası: ${e.toString()}');
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