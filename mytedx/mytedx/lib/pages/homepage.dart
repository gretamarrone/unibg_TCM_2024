import 'package:flutter/material.dart';
import 'video_navigation.dart';
import '../models/talk.dart'; // Assumendo che tu abbia un modello per gestire i dati degli utenti
import 'profile_page.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 221, 243, 225),
        title: const Text('Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Logout effettuato con successo"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop(); // Chiudi il dialog
                        Navigator.of(context).pushNamed('/'); // Vai alla pagina principale (main.dart)
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Naviga alla pagina del profilo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()), // Naviga verso ProfilePage
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color.fromARGB(255, 221, 243, 225),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Digita il titolo del video TEDx...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: VideoNavigation(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 221, 243, 225),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Naviga alla pagina del profilo
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()), // Naviga verso ProfilePage
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Implementa l'azione per le notifiche
              },
            ),
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                // Implementa l'azione per i gruppi
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                // Implementa l'azione per i preferiti
              },
            ),
          ],
        ),
      ),
    );
  }
}
