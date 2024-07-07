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
        title: const Text('Profilo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nome: $userName'),
            Text('Cognome: $userSurname'),
            Text('Email: $userEmail'),
            Text('Ruolo: $userRole'),
            // Aggiungi altri campi a seconda delle informazioni che vuoi mostrare
          ],
        ),
      ),
    );
  }
}
