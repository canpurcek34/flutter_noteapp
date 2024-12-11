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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _filteredNotes = [];
  List<dynamic> _filteredLists = [];
  final AppService _appService = AppService();
  List<dynamic> _notes = [];
  List<dynamic> _lists = [];
  late TabController _tabController;
  bool isLoading = true;
  bool isChecked = false;
  bool isDarkMode = false;
  String selectedMode = "Açık Mod";
  String? formattedDate;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    fetchNotes();
    fetchLists();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // AppBar widget'ını güncelleyelim
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ara...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: _filterItems,
            )
          : const Text('Notebook'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _filteredNotes = _notes;
                _filteredLists = _lists;
              }
            });
          },
        ),
        Switch.adaptive(
          value: isDarkMode,
          onChanged: (_) => _toggleTheme(),
          activeColor: Colors.cyan,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(icon: Icon(Icons.note), text: "Notlar"),
          Tab(icon: Icon(Icons.list), text: "Listeler"),
        ],
      ),
    );
  }

  // Navigation Drawer widget'ı
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.note_alt_outlined,
                      size: 30, color: Colors.cyan),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Notebook',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Notlarınız & Listeleriniz',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notlar'),
            onTap: () {
              _tabController.animateTo(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Listeler'),
            onTap: () {
              _tabController.animateTo(1);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
            onTap: () {
              _toggleTheme();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

// Arama filtreleme fonksiyonu
  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
        _filteredLists = _lists;
      } else {
        _filteredNotes = _notes
            .where((note) =>
                note['title']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                note['note']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();

        _filteredLists = _lists
            .where((list) =>
                list['title']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                list['note']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
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
                elevation: 4,
              ),
              colorScheme: ColorScheme.dark(
                primary: Colors.cyan,
                secondary: Colors.cyanAccent,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.cyan,
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.cyan,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.cyan,
                elevation: 4,
              ),
              colorScheme: ColorScheme.light(
                primary: Colors.cyan,
                secondary: Colors.cyanAccent,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.cyan,
              ),
            ),
      child: Scaffold(
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.cyan,
          foregroundColor: isDarkMode ? Colors.white : Colors.black87,
          overlayColor: Colors.black12,
          overlayOpacity: 0.4,
          spacing: 10,
          children: [
            SpeedDialChild(
              child: Icon(Icons.note_add,
                  color: isDarkMode ? Colors.white : Colors.black87),
              backgroundColor: Colors.cyan,
              label: 'Yeni Not Ekle',
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.black87 : Colors.black87,
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddNoteScreen()),
                );
                if (result == true) fetchNotes();
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.list,
                  color: isDarkMode ? Colors.white : Colors.black87),
              backgroundColor: Colors.cyan,
              label: 'Yeni Liste Ekle',
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.black87 : Colors.black87,
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddListScreen()),
                );
                if (result == true) fetchLists();
              },
            ),
          ],
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: TabBarView(
            controller: _tabController,
            children: [
              NotesTab(
                crossCount: crossCount,
                notes: _isSearching ? _filteredNotes : _notes,
                onDelete: deleteNote,
                onEdit: (id) async {
                  final note =
                      _notes.firstWhere((n) => n['id'].toString() == id);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(note: note),
                    ),
                  );
                  if (result == true) fetchNotes();
                },
                onColorChanged: (String id, Color color) {
                  showColorPicker(id, color);
                },
              ),
              ListsTab(
                lists: _isSearching ? _filteredLists : _lists,
                onDelete: deleteList,
                isChecked: isChecked,
                onEdit: (id) async {
                  final list =
                      _lists.firstWhere((n) => n['id'].toString() == id);
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
                },
                onColorChanged: (String id, Color color) {
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
        _filteredNotes = _notes;
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
        _filteredLists = _lists;
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
      setState(() async {
        await fetchNotes();
        await fetchLists();
        _refreshController.refreshCompleted();
      }); // Ekstra güncellenme için
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
                bool success =
                    await ColorService.updateColor(id, selectedColor);
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

  // Theme preference yükleme metodu
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      selectedMode = isDarkMode ? "Açık Mod" : "Koyu Mod";
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
      selectedMode = isDarkMode ? "Açık Mod" : "Koyu Mod";
      _saveThemePreference(isDarkMode);
    });
  }
}
