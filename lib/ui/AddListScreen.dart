import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/error_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';

class AddListScreen extends StatefulWidget {
  final bool isDialog;
  const AddListScreen({super.key, this.isDialog = false});
  @override
  _AddListScreenState createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listController = TextEditingController();
  bool _isLoading = false;
  String get _formattedDate =>
      DateFormat.yMMMMd('tr_TR').add_jm().format(DateTime.now());

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

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
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/list/insert.php'),
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
          ErrorUtils.showErrorSnackBar(
              context, responseData['message'] ?? "Bir hata oluştu");
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorUtils.showErrorSnackBar(
            context, 'Bağlantı hatası: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.currentTheme.brightness == Brightness.dark;
    final surfaceColor =
        isDarkMode ? Colors.grey.shade800 : Colors.pink.shade50;
    final buttonColor =
        isDarkMode ? Colors.grey.shade900 : Colors.pink.shade100;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintTextColor =
        isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black54;

    return widget.isDialog
        ? Dialog(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _listController,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: hintTextColor,
                            ),
                            labelText: 'Liste',
                            hintText: 'Liste içeriğini girin',
                            filled: true,
                            fillColor: surfaceColor,
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
                            backgroundColor: buttonColor,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Kaydet',
                                  style:
                                      TextStyle(fontSize: 16, color: textColor),
                                ),
                        ),
                      ],
                    ),
                  ),
                )))
        : Scaffold(
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
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
                          labelText: 'Liste',
                          hintText: 'Liste içeriğini girin',
                          filled: true,
                          fillColor: surfaceColor,
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
                          backgroundColor: buttonColor,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Kaydet',
                                style:
                                    TextStyle(fontSize: 16, color: textColor),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
