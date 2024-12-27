//ui/HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_noteapp/authpages/auth_screen.dart';
import 'package:flutter_noteapp/provider/theme_provider.dart';
import 'package:flutter_noteapp/service/app_service.dart';
import 'package:flutter_noteapp/ui/add_list_screen.dart';
import 'package:flutter_noteapp/ui/add_note_screen.dart';
import 'package:flutter_noteapp/ui/edit_list_screen.dart';
import 'package:flutter_noteapp/ui/edit_note_screen.dart';
import 'package:flutter_noteapp/widgets/lists_tab.dart';
import 'package:flutter_noteapp/widgets/notes_tab.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late TabController _tabController;
  bool isChecked = false;
  late AnimationController _refreshAnimationController;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final viewModel = Provider.of<HomeViewModel>(context, listen: false);
           viewModel.fetchNotes();
           viewModel.fetchLists();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
                setState(() {});
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

  Widget _buildDrawer(BuildContext context) {
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
            leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(themeProvider.isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
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
              _logout(context);
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
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
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
                await _showAddNoteDialog(context);
               
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
                 await _showAddListDialog(context);
            },
            ),
          ],
        ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        controller: _refreshController,
        onRefresh: () => _onRefresh(context),
         child:  viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            :   TabBarView(
              controller: _tabController,
            children: [
                  NotesTab(
                    crossCount: noteCross,
                 notes: _isSearching ? _filterNotes(viewModel.notes) : viewModel.notes,
                    onDelete: (id) => _deleteNote(context,id),
                 onEdit: (id)  {
                     final note =
                          viewModel.notes.firstWhere((n) => n['id'].toString() == id);
                     _showEditNoteDialog(context, note);
                   },
                    onColorChanged: (String id, Color color) {
                      showColorPicker(context,id, color);
                    },
                  ),
               ListsTab(
                   crossCount: listCross,
                    lists:  _isSearching ? _filterLists(viewModel.lists) : viewModel.lists,
                 onDelete: (id) => _deleteList(context,id),
                    onEdit: (id)  {
                      final list =
                            viewModel.lists.firstWhere((n) => n['id'].toString() == id);
                         _showEditListDialog(context, list);
                    },
                    onChanged: (String id, bool value) {
                           _updateCheckbox(context, id, value);
                    },
                      isChecked: isChecked,
                 onColorChanged: (String id, Color color) {
                   showColorPicker(context,id, color);
                 },
                  ),
                ],
              ),
        ),
    );
  }
  Widget _buildRefreshButton() {
    return RotationTransition(
          turns: _refreshAnimationController,
        child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _onRefresh(context);
            }
          ),
    );
  }
  Future<void> _onRefresh(BuildContext context) async {
    _refreshAnimationController.repeat();
     final viewModel = Provider.of<HomeViewModel>(context, listen: false);
     try {
          await  viewModel.fetchNotes();
          await viewModel.fetchLists();
        await Future.delayed(const Duration(seconds: 1), () {
          _refreshAnimationController.stop();
         _refreshController.refreshCompleted();
       });
    } catch (e) {
        _refreshAnimationController.stop();
         _refreshController.refreshFailed();
       ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Hata: $e'),  behavior: SnackBarBehavior.floating)
         );
    }
    }


    Future<void> _updateCheckbox(BuildContext context,String id, bool value) async {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    try {
       await viewModel.updateCheckbox(id,value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Hata: $e'),  behavior: SnackBarBehavior.floating)
         );
    }
  }

  Future<void> _deleteNote(BuildContext context, String id) async {
     final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    try {
      await viewModel.deleteNote(id);
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not başarıyla silindi.'),
           behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Hata: $e'),  behavior: SnackBarBehavior.floating)
         );
    }
  }

  Future<void> _deleteList(BuildContext context, String id) async {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    try {
      await viewModel.deleteList(id);
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
           content: Text('Liste başarıyla silindi.'),
         behavior: SnackBarBehavior.floating,
         ),
       );
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Hata: $e'),  behavior: SnackBarBehavior.floating)
         );
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
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


  void showColorPicker(BuildContext context, String id, Color currentColor) {
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

                          final viewModel = Provider.of<HomeViewModel>(context, listen: false);
                        await viewModel.fetchLists();
                        await viewModel.fetchNotes();
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
        final viewModel = Provider.of<HomeViewModel>(context, listen: false);

      if (MediaQuery.of(context).size.width >= 600) {
      return await showDialog(
           context: context,
            barrierDismissible: true,
        builder: (BuildContext context) {
             return ChangeNotifierProvider(
             create: (_) => HomeViewModel(),
              child: const AddNoteScreen(isDialog: true,));
        }).then((value) => {
             if(value == true)
              {
                viewModel.fetchNotes(),
                viewModel.fetchLists()
              }
          });
    } else {
    return await Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
               create: (_) => HomeViewModel(),
              child: const AddNoteScreen())),
        ).then((value) => {
           if(value == true)
              {
                viewModel.fetchNotes(),
                  viewModel.fetchLists()
              }
          });
   }
  }
  Future<dynamic> _showEditNoteDialog(BuildContext context, Map<String,dynamic> note) async {
        final viewModel = Provider.of<HomeViewModel>(context, listen: false);

     if (MediaQuery.of(context).size.width >= 600) {
        return await showDialog(
            context: context,
            builder: (context) => ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
             child:  EditNoteScreen(note: note, isDialog: true,),
          )
        ).then((value) => {
           if(value == true)
            {
               viewModel.fetchNotes(),
                viewModel.fetchLists()
            }
        });
   } else {
        return  await Navigator.push(
            context,
          MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
             child: EditNoteScreen(note: note,)),
         )
         ).then((value) => {
           if(value == true)
            {
                viewModel.fetchNotes(),
                viewModel.fetchLists()
            }
        });
    }
  }
    Future<dynamic> _showAddListDialog(BuildContext context) async {
        final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    if (MediaQuery.of(context).size.width >= 600) {
      return await showDialog(
        context: context,
          barrierDismissible: true,
        builder: (BuildContext context) {
            return  ChangeNotifierProvider(
                 create: (_) => HomeViewModel(),
               child:const AddListScreen(isDialog: true,));
       }).then((value) => {
           if(value == true)
              {
                  viewModel.fetchLists(),
                  viewModel.fetchNotes()
              }
          });
    } else {
       return await Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
              create: (_) => HomeViewModel(),
            child:const AddListScreen())),
         ).then((value) => {
            if(value == true)
              {
                  viewModel.fetchLists(),
                   viewModel.fetchNotes()
              }
         });
    }
  }
    Future<dynamic> _showEditListDialog(BuildContext context,Map<String,dynamic> list) async {
     final viewModel = Provider.of<HomeViewModel>(context, listen: false);
     if (MediaQuery.of(context).size.width >= 600) {
       return await showDialog(
        context: context,
         builder: (context) => ChangeNotifierProvider(
              create: (_) => HomeViewModel(),
            child: EditListScreen(list: list, isDialog: true,),
         ),
       ).then((value) => {
         if(value == true)
              {
                 viewModel.fetchLists(),
                viewModel.fetchNotes()
              }
        });
    } else {
        return await Navigator.push(
            context,
           MaterialPageRoute(builder: (context) =>  ChangeNotifierProvider(
             create: (_) => HomeViewModel(),
            child: EditListScreen(list: list,)))
           ).then((value) => {
            if(value == true)
              {
               viewModel.fetchLists(),
                viewModel.fetchNotes()
             }
          });

    }
  }
}
