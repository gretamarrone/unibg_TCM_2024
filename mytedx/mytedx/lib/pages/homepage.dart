import 'package:flutter/material.dart';
import 'video_navigation.dart'; // Importa il file per la navigazione dei video
import '../models/talk.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 221, 243, 225), // Cambia il colore della barra superiore
        title: const Text('Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Icona di logout
            onPressed: () {
              // Implementazione dell'azione per il logout
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
        ],
        automaticallyImplyLeading: false, // Rimuove la freccia indietro
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prima barra in alto (fissa) per il titolo del video TEDx
          Container(
            color: const Color.fromARGB(255, 221, 243, 225), // Cambia il colore della barra di ricerca
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              // per chiamare la funzione
              // controller: _controller1,
              decoration: InputDecoration(
                hintText: 'Digita il titolo del video TEDx...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          // Navigazione dei video
          Expanded(
            child: VideoNavigation(), // Utilizza il widget per la navigazione dei video
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 221, 243, 225), // Cambia il colore della barra inferiore
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Implementa l'azione per il profilo
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