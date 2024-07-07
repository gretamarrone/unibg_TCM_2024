// profile_page.dart

import 'package:flutter/material.dart';
import '../main.dart';


// Dentro ProfilePage:
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accedi alle informazioni dell'utente tramite l'email dell'utente loggato
    String userEmail = loggedInUserEmail;
    Map<String, dynamic>? userData = users[userEmail];

    // Verifica se l'utente è presente nel Map
    if (userData == null) {
      // Gestisci il caso in cui non trovi le informazioni dell'utente
      return Scaffold(
        appBar: AppBar(
          backgroundColor:  Color.fromARGB(255, 255, 237, 75), // giallo
          title: const Text('Profilo'),
        ),
        body: const Center(
          child: Text('Informazioni utente non trovate'),
        ),
      );
    }

    // Estrai le informazioni necessarie
    String userName = userData['name'];
    String userSurname = userData['surname'];
    String userRole = userData['role'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 37, 155, 151), // verde acqua      
        title: const Text('Profilo'),
      ),
      body: Container(
        color: Color.fromARGB(255, 230, 248, 247), // verde acqua chiaro
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nome: $userName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Colore del testo
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cognome: $userSurname',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Colore del testo
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: $userEmail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Colore del testo
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ruolo: $userRole',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Colore del testo
                ),
              ),
              // Aggiungi altri campi a seconda delle informazioni che vuoi mostrare
            ],
          ),
        ),
      ),
    );
  }
}