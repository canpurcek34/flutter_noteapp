// ui/AddListScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_noteapp/viewmodels/add_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddListScreen extends StatelessWidget {
  final bool isDialog;
  const AddListScreen({super.key, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddListViewModel(),
      child: _AddListScreenContent(isDialog: isDialog),
    );
  }
}

class _AddListScreenContent extends StatefulWidget {
  final bool isDialog;
  const _AddListScreenContent({this.isDialog = false});

  @override
  _AddListScreenContentState createState() => _AddListScreenContentState();
}

class _AddListScreenContentState extends State<_AddListScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _listController = TextEditingController();

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddListViewModel>(context);
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
                                    viewModel.addList(
                                      context,
                                      _listController.text,
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
                                  viewModel.addList(
                                    context,
                                    _listController.text,
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
