class Talk {
  final String id;
  final String title;
  final String url;
  final String tagCurrent;
  final List<String> idRelated;
  final List<String> titleRelated;
  final List<String> tagRelated;

  Talk({
    required this.id,
    required this.title,
    required this.url,
    required this.tagCurrent,
    required this.idRelated,
    required this.titleRelated,
    required this.tagRelated,
  });

  factory Talk.fromCsv(List<dynamic> row) {
    return Talk(
      id: row[0].toString(), // Convertire in stringa
      title: row[1].toString(),
      url: row[2].toString(),
      tagCurrent: row[3].toString(),
      idRelated: row[4].toString().split(','),
      titleRelated: row[5].toString().split(','),
      tagRelated: row[6].toString().split(','),
    );
  }
}
