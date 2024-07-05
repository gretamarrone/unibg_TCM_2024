import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/talk.dart';


// CODICE talk_repository.dart
/*
Future<List<Talk>> initEmptyList() async {

  Iterable list = json.decode("[]");
  var talks = list.map((model) => Talk.fromJSON(model)).toList();
  return talks;

}

Future<List<Talk>> getTalksByTag(String tag, int page) async {
  var url = Uri.parse('https://zwyitz95oe.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag2');

  final http.Response response = await http.post(url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, Object>{
      'tag': tag,
      'page': page,
      'doc_per_page': 6
    }),
  );
  if (response.statusCode == 200) {
    Iterable list = json.decode(response.body);
    var talks = list.map((model) => Talk.fromJSON(model)).toList();
    return talks;
  } else {
    throw Exception('Failed to load talks');
  }
      
}
*/
//



// codice pagina
class VideoNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Barra non fissa per navigare tra categorie, popolari, suggeriti
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Categorie'),
                Tab(text: 'Popolari'),
                Tab(text: 'Suggeriti'),
              ],
            ),
          ),
          // Contenuto delle schede
          const Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Categorie')),
                Center(child: Text('Popolari')),
                Center(child: Text('Suggeriti')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
