const connect_to_db = require('./db'); // Importa la funzione per connettersi al database

// GET WATCH NEXT BY TAG HANDLER

const next = require('./Next'); // Importa il modello 'Next'

module.exports.watch_next_by_tag = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false; // Impedisce che la funzione Lambda attenda che l'event loop sia vuoto prima di restituire una risposta

    console.log('Received event:', JSON.stringify(event, null, 2)); // Logga l'evento ricevuto per il debug

    let body = {}; // Inizializza un oggetto vuoto per il corpo della richiesta
    if (event.body) {
        body = JSON.parse(event.body); // Se l'evento ha un corpo, lo parsifica da JSON
    }

    // Controlla se l'ID è presente nel corpo della richiesta
    if(!body.tag) {
        callback(null, {
            statusCode: 500, 
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the related talks. Tag is null.' 
        });
        return; // Esce dalla funzione se il tag non è presente
    }

    if (!body.doc_per_page) {
        body.doc_per_page = 10
    }
    if (!body.page) {
        body.page = 1
    }


    var slice= {}
    if (body.slice) {
        slice = { tag_related: { $slice: body.slice} }
    }


    connect_to_db().then(() => { // Connette al db
        console.log('=> get watch next talks by tags'); 

        next.find({ _id: body._id }, slice) 
            .sort({ tf_idf: 1 }) 
            .skip((body.doc_per_page * body.page) - body.doc_per_page)
            .limit(body.doc_per_page)
            .then(talks =>{
                callback(null, {
                    statusCode: 200, // successo
                    body: JSON.stringify(talks.tag_related) // Restituisce l'intero oggetto come stringa JSON
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
