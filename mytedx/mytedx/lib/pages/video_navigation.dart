import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';  // Importa la libreria csv
import 'package:url_launcher/url_launcher.dart'; // Per aprire URL
import '../models/talk.dart';


class VideoNavigation extends StatefulWidget {
  @override
  _VideoNavigationState createState() => _VideoNavigationState();
}

class _VideoNavigationState extends State<VideoNavigation> {
  late Future<List<Talk>> futureTalks;
  Map<String, List<Talk>> tagMap = {};
  String? selectedTag;

  @override
  void initState() {
    super.initState();
    futureTalks = loadCsvData();
  }

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
          Expanded(
            child: FutureBuilder<List<Talk>>(
              future: loadCsvData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Errore nel caricamento dei dati'));
                } else {
                  final talks = snapshot.data!;
                  return TabBarView(
                    children: [
                      buildTags(talks),// Mostra tutti i dati nella scheda "Categorie"
                      buildPopular(talks), //  "Popolari", da aggiungere TF IDF 
                      const Center(child: Text('Suggeriti')), // Placeholder per "Suggeriti"
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPopular(List<Talk> talks) {
  // Ordina i talk per popolarità decrescente
  talks.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

  return buildList(talks); // Utilizza buildList per mostrare i talk ordinati
}


  Widget buildList(List<Talk> talks) {
    return ListView.builder(
      itemCount: talks.length,
      itemBuilder: (context, index) {
        final talk = talks[index];
        return Card(
          margin: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  talk.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    if (await canLaunch(talk.url)) {
                      await launch(talk.url);
                    } else {
                      throw 'Could not launch ${talk.url}';
                    }
                  },
                  child: const Text(
                    'Guarda ora',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5.0,
                  children: talk.tagCurrent.split(',').map((tag) {
                    return Chip(
                      label: Text(tag.trim()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Popularity Score: ${talk.popularityScore}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget buildTags(List<Talk> talks) {
    // Costruisci una mappa di tag e i talk associati a ciascun tag
    tagMap.clear();
    for (var talk in talks) {
      for (var tag in talk.tagCurrent.split(',')) {
        tag = tag.trim();
        if (tagMap.containsKey(tag)) {
          tagMap[tag]!.add(talk);
        } else {
          tagMap[tag] = [talk];
        }
      }
    }

    // Ordina i tag in ordine alfabetico
    var sortedTags = tagMap.keys.toList()..sort();

    return selectedTag == null
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center, // Centra i tag all'interno della riga
              children: sortedTags.map((tag) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ChoiceChip(
                      label: Text(tag.trim()),
                          selected: selectedTag == tag.trim(),
                          onSelected: (selected) {
                            setState(() {
                              selectedTag = selected ? tag.trim() : null;
                            });
                          },
                    ),
                );
              }).toList(),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        selectedTag = null;
                      });
                    },
                  ),
                  Text(
                    'Talk con il tag: "$selectedTag"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                child: buildList(tagMap[selectedTag]!),
              ),
            ],
          );
  }
}

class TalkListByTag extends StatelessWidget {
  final String tag;
  final List<Talk> talks;

  const TalkListByTag({required this.tag, required this.talks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talks for tag: $tag'),
      ),
      body: ListView.builder(
        itemCount: talks.length,
        itemBuilder: (context, index) {
          final talk = talks[index];
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talk.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch(talk.url)) {
                        await launch(talk.url);
                      } else {
                        throw 'Could not launch ${talk.url}';
                      }
                    },
                    child: const Text(
                      'Guarda ora',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tags: ${talk.tagCurrent}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 5.0,
                    children: talk.tagCurrent.split(',').map((tag) {
                      return Chip(
                        label: Text(tag.trim()),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}




Future<List<Talk>> loadCsvData() async {
  try {
    final data = await rootBundle.loadString('assets/processed_data_with_popularity.csv');
    print('File CSV caricato con successo');  // Log per il successo del caricamento del file
    List<List<dynamic>> csvTable = CsvToListConverter().convert(data);
    List<Talk> talks = csvTable.skip(1).map((row) => Talk.fromCsv(row)).toList();
    print('Dati CSV convertiti con successo');  // Log per il successo della conversione
    return talks;
  } catch (e) {
    print('Errore durante il caricamento o la conversione dei dati CSV: $e');  // Log dell'errore
    throw e;
  }}
