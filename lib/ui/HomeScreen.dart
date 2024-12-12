import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_noteapp/authpages/AuthScreen.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../service/AppService.dart';
import '../widgets/ListsTab.dart';
import '../widgets/NotesTab.dart';
import 'AddListScreen.dart';
import 'AddNoteScreen.dart';
import 'EditListScreen.dart';
import 'EditNoteScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  String selectedMode = "Açık Mod";
  String? formattedDate;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    fetchNotes();
    fetchLists();
    _tabController = TabController(length: 2, vsync: this);
    _refreshAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
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
        _buildRefreshButton(),
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

  Widget _buildDrawer() {
      final themeProvider = Provider.of<ThemeProvider>(context);
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
            leading: Icon( themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text( themeProvider.isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
            onTap: () {
                    themeProvider.toggleTheme();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
                 leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              _logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int noteCross = screenWidth < 600 ? 2 : 4;
    int listCross = screenWidth < 600 ? 1 : 4;
    return Scaffold(
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.cyan,
          foregroundColor:   Provider.of<ThemeProvider>(context).currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black87,
          overlayColor: Colors.black12,
          overlayOpacity: 0.4,
          spacing: 10,
          children: [
            SpeedDialChild(
              child: Icon(Icons.note_add,
                         color:  Provider.of<ThemeProvider>(context).currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black87),
              backgroundColor: Colors.cyan,
                 label: 'Yeni Not Ekle',
                  labelStyle: TextStyle(
                color: Provider.of<ThemeProvider>(context).currentTheme.brightness == Brightness.dark ? Colors.black87:Colors.black87,
              ),
              onTap: () async {
                final result = await _showAddNoteDialog(context);
                if (result == true) fetchNotes();
              },
            ),
            SpeedDialChild(
            child: Icon(Icons.list,
              color: Provider.of<ThemeProvider>(context).currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black87
            ),
            backgroundColor: Colors.cyan,
              label: 'Yeni Liste Ekle',
                  labelStyle: TextStyle(
                     color: Provider.of<ThemeProvider>(context).currentTheme.brightness == Brightness.dark ? Colors.black87:Colors.black87
                  ),
                    onTap: () async {
                 final result = await _showAddListDialog(context);
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
                crossCount: noteCross,
                notes: _isSearching ? _filteredNotes : _notes,
                onDelete: deleteNote,
                onEdit: (id) async {
                    final note =
                        _notes.firstWhere((n) => n['id'].toString() == id);
                    final result = await _showEditNoteDialog(context, note);
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
                    final result = await _showEditListDialog(context, list);
                  if (result == true) fetchLists();
                  },
                crossCount: listCross,
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
        "orange": Colors.orange,
        "grey": Colors.grey,
        "purple": Colors.purple,
        "cyan": Colors.cyan,
        "white": Colors.white
      };

      for (var _colors in lists) {
        String colorName = _colors['color'] ?? 'white';
        _colors['flutterColor'] = colorNames[colorName] ?? Colors.white;
      }
      await initializeDateFormatting('tr_TR', null);
      final DateFormat formatter = DateFormat('d MMMM y HH:mm', 'tr_TR');
      setState(() {
        _lists = lists
          ..sort((a, b) {
            DateTime dateA = formatter.parse(a['date']);
           DateTime dateB = formatter.parse(b['date']);
             return dateB.compareTo(dateA);
         });
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapılırken bir hata oluştu: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
         _filteredLists = _lists;
      } else {
        _filteredNotes = _notes
            .where((note) =>
                note['title']
                        ?.toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()) ==
                    true ||
                 note['note']
                        ?.toString()
                       .toLowerCase()
                       .contains(query.toLowerCase()) ==
                   true)
             .toList();
          _filteredLists = _lists
              .where((list) =>
                  list['list']
                    ?.toString()
                    .toLowerCase()
                  .contains(query.toLowerCase()) ==
                   true)
              .toList();

      }
    });
  }


  void _onRefresh() async {
    _refreshAnimationController.repeat();
    try {
      await fetchNotes();
    await fetchLists();
      await Future.delayed(const Duration(seconds: 1), () {
          _refreshAnimationController.stop();
        _refreshController.refreshCompleted();
       });
    } catch (e) {
     _refreshAnimationController.stop();
      _refreshController.refreshFailed();
       _showError(e.toString());
    }
  }

   Widget _buildRefreshButton() {
    return RotationTransition(
          turns: _refreshAnimationController,
        child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
    );
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
                   Colors.orange,
                     Colors.grey,
               Colors.purple,
                     Colors.cyan,
                    Colors.white
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
                        fetchLists();// Refresh lists to show updated color
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


   Future<dynamic> _showAddNoteDialog(BuildContext context) async {
    if (MediaQuery.of(context).size.width >= 600) {
      return await showDialog(
           context: context,
            barrierDismissible: true,
        builder: (BuildContext context) {
             return const AddNoteScreen(isDialog: true,);
        });
    } else {
    return await Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const AddNoteScreen()),
        );
   }
}
  Future<dynamic> _showEditNoteDialog(BuildContext context, Map<String,dynamic> note) async {
    if (MediaQuery.of(context).size.width >= 600) {
      return await showDialog(
         context: context,
         barrierDismissible: true,
        builder: (BuildContext context) {
         return  EditNoteScreen(note: note, isDialog: true,);
        });
   } else {
        return  await Navigator.push(
            context,
          MaterialPageRoute(builder: (context) => EditNoteScreen(note: note,)),
         );
    }
  }
  Future<dynamic> _showAddListDialog(BuildContext context) async {
    if (MediaQuery.of(context).size.width >= 600) {
      return await showDialog(
        context: context,
          barrierDismissible: true,
        builder: (BuildContext context) {
            return const AddListScreen(isDialog: true);
       });
    } else {
       return await Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AddListScreen()),
         );
    }
  }
  Future<dynamic> _showEditListDialog(BuildContext context,Map<String,dynamic> list) async {
    if (MediaQuery.of(context).size.width >= 600) {
      return await showDialog(
         context: context,
          barrierDismissible: true,
        builder: (BuildContext context) {
          return EditListScreen(list: list, isDialog: true,);
        });
    } else {
        return await Navigator.push(
            context,
           MaterialPageRoute(builder: (context) =>  EditListScreen(list: list,))
           );

    }
  }
}
