/*

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'talk.dart';
import 'next.dart';

Future<List<Talk>> initEmptyList() async {

  Iterable list = json.decode("[]");
  var talks = list.map((model) => Talk.fromJSON(model)).toList();
  return talks;

}

// get talks by tag
Future<List<Talk>> getTalksByTag(String tag, int page) async {
  var url = Uri.parse('https://b3zz9i7ati.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag');

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

// Watch Next
Future<List<Next>> getWatchNextById(String id, int page) async {
  var url = Uri.parse('https://324tbf4ft8.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next_by_Id');
  try {
    final http.Response response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        'id': id,
        'page': page,
        'doc_per_page': 6
      }),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
        if(jsonResponse != null && jsonResponse.isNotEmpty) {
          List<Next> next = jsonResponse.map((model){
            return Next.fromJSON(model);
          }).toList();
          if(next.isEmpty){
            throw Exception("No talks found with this id");
          }
          return next;
        } else {
          throw Exception("Empty or invalid response");
        }      
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
  } catch (e) {
    print("Error occurred");
    throw Exception(".");
  }
} 




// getTalksByTitle
Future<List<Talk>> getTalksByTitle(String title, int page) async {
  var url = Uri.parse('https://9dsv44yb5.execute-api.us-east-1.amazonaws.com/default/Get_Talks_by_Title');

  final http.Response response = await http.post(url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, Object>{
      'title': title,
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


// getTalksByScore
Future<List<Talk>> getTalksByScore(int page) async {
  var url = Uri.parse('https://y7jd83923eo2j.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Score');

  final http.Response response = await http.post(url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, Object>{
      'page': page,
      'doc_per_page': 6,
      'sort_by': 'tf-idf', // Assuming 'tf-idf' is the correct key for sorting by score
      'order': 'asc' // To sort in ascending order
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