import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/error_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EditListScreen extends StatefulWidget {
  final Map<String, dynamic> list;

  const EditListScreen({Key? key, required this.list}) : super(key: key);

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
    if(_isLoading) return;
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
          ErrorUtils.showErrorSnackBar(
              context, 'Hata: ${data['message']}');
         }
      }
    } catch (e) {
     if (mounted) {
        ErrorUtils.showErrorSnackBar(
            context, 'Bir hata oluştu: $e');
    }
    } finally {
      if(mounted) {
         setState(() {
          _isLoading = false;
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
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
                    decoration:  InputDecoration(
                    hintText: 'Listeyi giriniz',
                       filled: true,
                           fillColor: Theme.of(context).colorScheme.surface,
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateList,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                         height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                           ),
                         )
                     : const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

