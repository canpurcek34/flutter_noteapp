import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/AppService.dart';
import '../widgets/ListsTab.dart';
import '../widgets/NotesTab.dart';
import 'AddListScreen.dart';
import 'AddNoteScreen.dart';
import 'EditListScreen.dart';
import 'EditNoteScreen.dart';


class MobileNotebookScreen extends StatefulWidget {
  const MobileNotebookScreen({super.key});

  @override
  _MobileNotebookScreenState createState() => _MobileNotebookScreenState();
}

class _MobileNotebookScreenState extends State<MobileNotebookScreen>
    with SingleTickerProviderStateMixin {
  final AppService _appService = AppService();
  List<dynamic> _notes = [];
  List<dynamic> _lists = [];
  late TabController _tabController;
  bool isLoading = true;
  bool isChecked = false;
  bool isDarkMode = false;
  String? formattedDate;
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    fetchNotes();
    fetchLists();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Theme preference yükleme metodu
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Theme preference kaydetme metodu
  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Theme değiştirme metodu
  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveThemePreference(isDarkMode);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossCount = screenWidth < 600 ? 1 : 4;

    return Theme(
      data: isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.cyan,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.cyan,
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notebook'),
          actions: [
            Row(
              children: [
                Text(
                  'Dark Mode', 
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (_) => _toggleTheme(),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.cyan,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.note), text: "Notlar"),
              Tab(icon: Icon(Icons.list), text: "Listeler"),
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.cyan,
          overlayOpacity: 0.1,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.note_add, color: Colors.white),
              backgroundColor: Colors.cyan,
              label: 'Yeni Not Ekle',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNoteScreen()),
                );
                if (result == true) fetchNotes();
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.list, color: Colors.white),
              backgroundColor: Colors.cyan,
              label: 'Yeni Liste Ekle',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddListScreen()),
                );
                if (result == true) fetchLists();
              },
            ),
          ],
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: TabBarView(
            controller: _tabController,
            children: [
              NotesTab(
                crossCount: crossCount,
                notes: _notes,
                onDelete: deleteNote,
                onEdit: (id) async {
                  final note = _notes.firstWhere((n) => n['id'].toString() == id);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(note: note),
                    ),
                  );
                  if (result == true) fetchNotes();
                }, onColorChanged: (String id, Color color) { 
                  showColorPicker(id, color);
                 },
              ),
              ListsTab(
                lists: _lists,
                onDelete: deleteList,
                isChecked: isChecked,
                onEdit: (id) async {
                  final list = _lists.firstWhere((n) => n['id'].toString() == id);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditListScreen(list: list),
                    ),
                  );
                  if (result == true) fetchLists();
                },
                crossCount: crossCount,
                onChanged: (String id, bool value) {
                  setState(() {
                    updateCheckbox(id, value);
                  });
                }, onColorChanged: (String id, Color color) { 
                  showColorPicker(id, color);
                 },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> fetchNotes() async {
    try {
      final notes = await _appService.fetchNotes();
      setState(() {
        _notes = notes..sort((a, b) => b['date'].compareTo(a['date']));
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> fetchLists() async {
    try {
      final lists = await _appService.fetchLists();

      Map<String, Color> colorNames = {
        "red": Colors.red,
        "blue": Colors.blue,
        "green": Colors.green,
        "yellow": Colors.yellow,
        "white": Colors.white,
        "orange": Colors.orange,
        "grey": Colors.grey,
        "purple": Colors.purple,
        "cyan": Colors.cyan,
      };

      for (var _colors in lists) {
        String colorName = _colors['color'] ?? 'white';
        _colors['flutterColor'] = colorNames[colorName] ?? Colors.white;
      }

      setState(() {
        _lists = lists..sort((a, b) => b['date'].compareTo(a['date']));
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> updateCheckbox(String id, bool value) async {
    try {
      await _appService.updateCheckbox(id, value);
      setState(() {
        fetchLists();
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _appService.deleteNote(id);
      fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not başarıyla silindi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await _appService.deleteList(id);
      fetchLists();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liste başarıyla silindi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _onRefresh() async {
    try {
      await fetchNotes();
      await fetchLists();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }
  void showColorPicker(String id, Color currentColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = currentColor;

        return AlertDialog(
          title: const Text('Bir renk seçin'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              availableColors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.black,
                Colors.white,
                Colors.orange,
                Colors.grey,
                Colors.purple,
                Colors.cyan,
              ],
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Tamam'),
              onPressed: () async {
                bool success = await ColorService.updateColor(id, selectedColor);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Renk başarıyla güncellendi')),
                  );
                  fetchLists(); // Refresh lists to show updated color
                  fetchNotes();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Renk güncellenemedi')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
