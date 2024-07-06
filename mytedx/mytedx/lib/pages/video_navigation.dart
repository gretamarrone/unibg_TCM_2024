import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/talk.dart';

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