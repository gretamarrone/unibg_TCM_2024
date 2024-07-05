class Next {
  final String id;
  final String url;
  final String title;
  final String mainSpeaker;
  final String publishedAt;

  Next.fromJSON(Map<String, dynamic> jsonMap) :
    id=jsonMap['_id'],
    url=jsonMap['url'],
    title = jsonMap['title'],
    mainSpeaker = (jsonMap['speakers'] ?? ""),
    publishedAt = (jsonMap['url'] ?? "");
}