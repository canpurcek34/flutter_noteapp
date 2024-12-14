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
  // ignore: unused_field
  List<dynamic> _filteredNotes = [];
  // ignore: unused_field
  List<dynamic> _filteredLists = [];
  late Future<List<dynamic>> _notesFuture;
  late Future<List<dynamic>> _listsFuture;
  late TabController _tabController;
  bool isLoading = true;
  bool isChecked = false;
  String selectedMode = "Açık Mod";
  String? formattedDate;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  late AnimationController _refreshAnimationController;
  final AppService _appService = AppService();

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
    _listsFuture = _fetchLists();
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
              onChanged: (query) {
                setState(() {
                  
                });
              },
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
                _filteredNotes = [];
                _filteredLists = [];
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
                if (result == true) {
                  setState(() {
                    _notesFuture = _fetchNotes();
                  });
                }
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
                if (result == true) {
                  setState(() {
                    _listsFuture = _fetchLists();
                  });
                }
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
              FutureBuilder<List<dynamic>>(
                future: _notesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Henüz not yok.'));
                  } else {
                    final notes = snapshot.data!;
                    return NotesTab(
                      crossCount: noteCross,
                      notes: _isSearching ? _filterNotes(notes) : notes,
                      onDelete: (id) => _deleteNote(id),
                      onEdit: (id) async {
                        final note =
                            notes.firstWhere((n) => n['id'].toString() == id);
                        final result = await _showEditNoteDialog(context, note);
                        if (result == true) {
                          setState(() {
                            _notesFuture = _fetchNotes();
                          });
                        }
                      },
                      onColorChanged: (String id, Color color) {
                        showColorPicker(id, color);
                      },
                    );
                  }
                },
              ),
              FutureBuilder<List<dynamic>>(
                future: _listsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Henüz liste yok.'));
                  } else {
                    final lists = snapshot.data!;
                    return ListsTab(
                      lists: _isSearching ? _filterLists(lists) : lists,
                      onDelete: (id) => _deleteList(id),
                      isChecked: isChecked,
                      onEdit: (id) async {
                        final list =
                            lists.firstWhere((n) => n['id'].toString() == id);
                        final result = await _showEditListDialog(context, list);
                        if (result == true) {
                          setState(() {
                            _listsFuture = _fetchLists();
                          });
                        }
                      },
                      crossCount: listCross,
                      onChanged: (String id, bool value) {
                        setState(() {
                          _updateCheckbox(id, value);
                        });
                      },
                      onColorChanged: (String id, Color color) {
                        showColorPicker(id, color);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
  }



  Future<List<dynamic>> _fetchNotes() async {
    try {
      final notes = await _appService.fetchNotes();
      return notes..sort((a, b) => b['date'].compareTo(a['date']));
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> _fetchLists() async {
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
      return lists
        ..sort((a, b) {
          DateTime dateA = formatter.parse(a['date']);
          DateTime dateB = formatter.parse(b['date']);
          return dateB.compareTo(dateA);
        });
    } catch (e) {
      _showError(e.toString());
      return [];
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _updateCheckbox(String id, bool value) async {
    try {
      await _appService.updateCheckbox(id, value);
      setState(() {
          _listsFuture = _fetchLists();
         });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
       await _appService.deleteNote(id);
          setState(() {
            _notesFuture = _fetchNotes();
          });
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

  Future<void> _deleteList(String id) async {
    try {
      await _appService.deleteList(id);
      setState(() {
        _listsFuture = _fetchLists();
      });
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

  List<dynamic> _filterNotes(List<dynamic> notes) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return notes;
    } else {
      return notes
          .where((note) =>
              note['title']
                      ?.toString()
                      .toLowerCase()
                      .contains(query) ==
                  true ||
               note['note']
                      ?.toString()
                     .toLowerCase()
                     .contains(query) ==
                 true)
           .toList();
    }
  }

  List<dynamic> _filterLists(List<dynamic> lists) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return lists;
    } else {
      return lists
          .where((list) =>
              list['list']
                ?.toString()
                .toLowerCase()
              .contains(query) ==
               true)
          .toList();
    }
  }


  void _onRefresh() async {
    _refreshAnimationController.repeat();
    try {
      setState(() {
        _notesFuture = _fetchNotes();
        _listsFuture = _fetchLists();
      });
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
                        setState(() {
                          _listsFuture = _fetchLists();
                          _notesFuture = _fetchNotes();
                        });
                        
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
