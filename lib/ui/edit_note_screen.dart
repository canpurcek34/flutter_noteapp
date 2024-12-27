// ui/EditNoteScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_noteapp/viewmodels/edit_note_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditNoteScreen extends StatelessWidget {
  final Map<String, dynamic> note;
  final bool isDialog;

  const EditNoteScreen({super.key, required this.note, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditNoteViewModel(),
      child: _EditNoteScreenContent(note: note, isDialog: isDialog),
    );
  }
}

class _EditNoteScreenContent extends StatefulWidget {
  final Map<String, dynamic> note;
  final bool isDialog;
  const _EditNoteScreenContent(
      {required this.note, this.isDialog = false});

  @override
  _EditNoteScreenContentState createState() => _EditNoteScreenContentState();
}

class _EditNoteScreenContentState extends State<_EditNoteScreenContent> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title'] ?? '');
    _noteController = TextEditingController(text: widget.note['note'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditNoteViewModel>(context);
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
                        alignLabelWithHint: true,
                        hintStyle: TextStyle(
                          color: hintTextColor,
                        ),
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
                                viewModel.updateNote(
                                  context,
                                  widget.note['id'].toString(),
                                  _titleController.text,
                                  _noteController.text,
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
          ))
        : Scaffold(
            appBar: AppBar(
              title: const Text('Düzenle'),
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
                          alignLabelWithHint: true,
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
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
                                  viewModel.updateNote(
                                    context,
                                    widget.note['id'].toString(),
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
