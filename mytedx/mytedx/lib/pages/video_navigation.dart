import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';  // Importa la libreria csv
import '../models/talk.dart';

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
                      buildList(talks), // Mostra tutti i dati nella scheda "Categorie"
                      const Center(child: Text('Popolari')), // Placeholder per "Popolari"
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

  Widget buildList(List<Talk> talks) {
    return ListView.builder(
      itemCount: talks.length,
      itemBuilder: (context, index) {
        final talk = talks[index];
        return ListTile(
          title: Text(talk.title),
          // Aggiungi altre proprietà come necessarie
        );
      },
    );
  }
}

Future<List<Talk>> loadCsvData() async {
  try {
    final data = await rootBundle.loadString('assets/processed_data.csv');
    print('File CSV caricato con successo');  // Log per il successo del caricamento del file
    List<List<dynamic>> csvTable = CsvToListConverter().convert(data);
    List<Talk> talks = csvTable.skip(1).map((row) => Talk.fromCsv(row)).toList();
    print('Dati CSV convertiti con successo');  // Log per il successo della conversione
    return talks;
  } catch (e) {
    print('Errore durante il caricamento o la conversione dei dati CSV: $e');  // Log dell'errore
    throw e;
  }}
