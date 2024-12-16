// ui/EditListScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_noteapp/viewmodels/edit_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditListScreen extends StatelessWidget {
  final Map<String, dynamic> list;
  final bool isDialog;

  const EditListScreen({super.key, required this.list, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditListViewModel(),
      child: _EditListScreenContent(list: list, isDialog: isDialog),
    );
  }
}

class _EditListScreenContent extends StatefulWidget {
  final Map<String, dynamic> list;
  final bool isDialog;
  const _EditListScreenContent(
      {super.key, required this.list, this.isDialog = false});

  @override
  _EditListScreenContentState createState() => _EditListScreenContentState();
}

class _EditListScreenContentState extends State<_EditListScreenContent> {
  late final TextEditingController _listController;
  late final String _originalDate;
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditListViewModel>(context);
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
                    viewModel.isLoading
                        ? const Center(
                            child: SpinKitChasingDots(
                              color: Colors.cyan,
                              size: 50.0,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                viewModel.updateList(
                                  context,
                                  widget.list['id'].toString(),
                                  _listController.text,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
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
                    viewModel.isLoading
                        ? const Center(
                            child: SpinKitChasingDots(
                              color: Colors.cyan,
                              size: 50.0,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                viewModel.updateList(
                                  context,
                                  widget.list['id'].toString(),
                                  _listController.text,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
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
