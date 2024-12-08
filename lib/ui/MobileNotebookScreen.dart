import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../service/AppService.dart';
import '../widgets/ListsTab.dart';
import '../widgets/NotesTab.dart';
import 'AddListScreen.dart';
import 'AddNoteScreen.dart';
import 'EditListScreen.dart';
import 'EditNoteScreen.dart';

class MobileNotebookScreen extends StatefulWidget {
  @override
  _MobileNotebookScreenState createState() => _MobileNotebookScreenState();
}

class _MobileNotebookScreenState extends State<MobileNotebookScreen>
    with SingleTickerProviderStateMixin {
  final AppService _appService = AppService();
  List<dynamic> _notes = [];
  List<dynamic> _lists = [];
  List<dynamic> _colors = [];
  late TabController _tabController;
  bool isLoading = true;
  bool isChecked = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    fetchNotes();
    fetchLists();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notebook'),
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
                MaterialPageRoute(builder: (context) => AddNoteScreen()),
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
                MaterialPageRoute(builder: (context) => AddListScreen()),
              );
              if (result == true) fetchLists();
            },
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false, // Yükleme devre dışı bırakıldı
        header: const WaterDropHeader(), // Daha görsel bir header
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
              },
            ),
          ],
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
        "black": Colors.black,
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
}
