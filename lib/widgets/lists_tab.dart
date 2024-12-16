import 'package:flutter/material.dart';
import 'package:flutter_noteapp/widgets/list_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ListsTab extends StatelessWidget {
  static final Map<String, Color> colorNames = {
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

  final List<dynamic> lists;
  final Function(String id) onDelete;
  final Function(String id) onEdit;
  final Function(String id, bool value) onChanged;
  final Function(String id, Color color) onColorChanged;
  final int crossCount;
  final bool isChecked;

  const ListsTab({
    super.key,
    required this.lists,
    required this.onDelete,
    required this.onEdit,
    required this.crossCount,
    required this.onChanged,
    required this.isChecked,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    int listCrossCount = crossCount;
    return MasonryGridView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: listCrossCount,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        final Color cardColor =
            colorNames[list['color']?.toLowerCase()] ?? Colors.transparent;
        return ListCard(
            id: list['id'].toString(),
            listItem: list['list'],
            isChecked: list['isChecked'],
            onDelete: onDelete,
            onCheckboxChanged: onChanged,
            onEdit: onEdit,
            cardColor: cardColor,
            colorPicker: onColorChanged);
      },
    );
  }
}