import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/error_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';

class EditListScreen extends StatefulWidget {
  final Map<String, dynamic> list;
  final bool isDialog;

  const EditListScreen({super.key, required this.list, this.isDialog = false});
  @override
  _EditListScreenState createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  late final TextEditingController _listController;
  late final String _originalDate;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _listController = TextEditingController(text: widget.list['list'] ?? '');
    _originalDate = widget.list['date'] ?? '';
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _updateList() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/list/update.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': widget.list['id'].toString(),
          'list': _listController.text,
          'date': formattedDate
        }),
      );
      final data = json.decode(response.body);

      if (data['success'] == 1) {
        if (mounted) {
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
      } else {
        if (mounted) {
          ErrorUtils.showErrorSnackBar(context, 'Hata: ${data['message']}');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorUtils.showErrorSnackBar(context, 'Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                        hintText: 'Listeyi giriniz',
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Düzenlenme Zamanı: $_originalDate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Kaydet',
                              style: TextStyle(fontSize: 16, color: textColor),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Düzenle'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                        hintText: 'Listeyi giriniz',
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Düzenlenme Zamanı: $_originalDate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Kaydet',
                              style: TextStyle(fontSize: 16, color: textColor),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
