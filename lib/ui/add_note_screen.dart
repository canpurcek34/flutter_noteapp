// ui/AddNoteScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_noteapp/viewmodels/add_note_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddNoteScreen extends StatelessWidget {
  final bool isDialog;
  const AddNoteScreen({super.key, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddNoteViewModel(),
      child: _AddNoteScreenContent(isDialog: isDialog),
    );
  }
}

class _AddNoteScreenContent extends StatefulWidget {
  final bool isDialog;
  const _AddNoteScreenContent({super.key, this.isDialog = false});

  @override
  _AddNoteScreenContentState createState() => _AddNoteScreenContentState();
}

class _AddNoteScreenContentState extends State<_AddNoteScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddNoteViewModel>(context);
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
                        controller: _titleController,
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
                          labelText: 'Başlık',
                          hintText: 'Not başlığını giriniz',
                          filled: true,
                          fillColor: surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Başlık giriniz' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
                          labelText: 'Not',
                          hintText: 'Notunuzu giriniz',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 8,
                        textInputAction: TextInputAction.newline,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Not giriniz' : null,
                      ),
                      const SizedBox(height: 24),
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
                                  viewModel.addNote(
                                    context,
                                    _titleController.text,
                                    _noteController.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Kaydet',
                                style:
                                    TextStyle(fontSize: 16, color: textColor),
                              ),
                            ),
                    ]),
              ),
            ),
          ))
        : Scaffold(
            appBar: AppBar(
              title: const Text('Yeni Not Ekle'),
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
                        controller: _titleController,
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
                          labelText: 'Başlık',
                          hintText: 'Not başlığını giriniz',
                          filled: true,
                          fillColor: surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Başlık giriniz' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
                          labelText: 'Not',
                          hintText: 'Notunuzu giriniz',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 8,
                        textInputAction: TextInputAction.newline,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Not giriniz' : null,
                      ),
                      const SizedBox(height: 24),
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
                                  viewModel.addNote(
                                    context,
                                    _titleController.text,
                                    _noteController.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
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
