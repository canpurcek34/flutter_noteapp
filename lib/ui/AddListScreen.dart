import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/error_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddListScreen extends StatefulWidget {
  const AddListScreen({super.key});

  @override
  _AddListScreenState createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listController = TextEditingController();
  bool _isLoading = false;

  String get _formattedDate => DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());

  Future<void> _addList() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ErrorUtils.showErrorDialog(context, "Kullanıcı oturumu yok");
      setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/list/insert.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'uuid': user.uid,
          'list': _listController.text,
          'color': "white",
          'isChecked': "0",
          'type': "list",
         'date': _formattedDate,
        }),
      );
      final responseData = json.decode(response.body);

      if (responseData['success'] == 1) {
        if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liste başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        }
      } else {
          if (mounted) {
            ErrorUtils.showErrorSnackBar(context, responseData['message'] ?? "Bir hata oluştu");
          }
      }
    } catch (e) {
        if (mounted) {
       ErrorUtils.showErrorSnackBar(context, 'Bağlantı hatası: ${e.toString()}');
        }
    } finally {
        if (mounted){
           setState(() => _isLoading = false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Liste Ekle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _listController,
                  decoration:  InputDecoration(
                     labelText: 'Liste',
                    hintText: 'Liste içeriğini girin',
                    filled: true,
                           fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide.none,
                   ),      
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Öğe giriniz' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addList,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                        height: 20,
                         width: 20,
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                       )
                      : const Text('Kaydet',style: TextStyle(fontSize: 16),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }
}
