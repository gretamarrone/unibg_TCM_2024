import 'package:flutter/material.dart';

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
            child: TabBar(
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
