class Notebook {
  final String title;
  final String note;
  final String uuid;
  final bool isChecked;

  Notebook(
      {required this.isChecked,
      required this.title,
      required this.note,
      required this.uuid});

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
        isChecked: json['isChecked'] == true,
        title: json['title'] as String,
        note: json['note'] as String,
        uuid: json['uuid'] as String);
  }
}
