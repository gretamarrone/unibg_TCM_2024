const connect_to_db = require('./db'); // Importa la funzione per connettersi al database

// GET WATCH NEXT BY ID HANDLER

const next = require('./Next'); // Importa il modello 'Next'

module.exports.watch_next_by_id = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false; // Impedisce che la funzione Lambda attenda che l'event loop sia vuoto prima di restituire una risposta

    console.log('Received event:', JSON.stringify(event, null, 2)); // Logga l'evento ricevuto per il debug

    let body = {}; // Inizializza un oggetto vuoto per il corpo della richiesta
    if (event.body) {
        body = JSON.parse(event.body); // Se l'evento ha un corpo, lo parsifica da JSON
    }

    // Controlla se l'ID è presente nel corpo della richiesta
    if(!body.id) {
        callback(null, {
            statusCode: 500, 
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the related talks. ID is null.' 
        });
        return; // Esce dalla funzione se l'ID non è presente
    }

    if (!body.doc_per_page) {
        body.doc_per_page = 10
    }
    if (!body.page) {
        body.page = 1
    }

    connect_to_db().then(() => { // Connette al db
        console.log('=> get watch next talks by ID'); 

        next.find({ id: body.id_related }) // Prendo id_related del talk, salvo i talk con quell'id
            .skip((body.doc_per_page * body.page) - body.doc_per_page)
            .limit(body.doc_per_page)
            .then(next =>{
                // Ora nextItem contiene l'intero oggetto trovato nel database
                callback(null, {
                    statusCode: 200, // successo
                    body: JSON.stringify(next) // Restituisce l'intero oggetto come stringa JSON
                    })
                }
            )
            .catch(err => { // Gestisce gli errori che si verificano durante la ricerca del talk
                callback(null, {
                    statusCode: err.statusCode || 500, 
                    headers: { 'Content-Type': 'text/plain' }, 
                    body: 'Could not fetch the related talks.' 
                });
            });
    }).catch(err => { // Gestisce gli errori che si verificano durante la connessione al database
        callback(null, {
            statusCode: 500, 
            headers: { 'Content-Type': 'text/plain' }, 
            body: 'Database connection failed.' 
        });
    });
};
