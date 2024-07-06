const express = require('express');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const app = express();
const port = 3000;

// Connetti al database SQLite
let db = new sqlite3.Database('./processed_data.db', (err) => {
    if (err) {
        console.error(err.message);
    }
    console.log('Connesso al database SQLite.');
});

// Middleware
app.use(bodyParser.json());

// Endpoint per ottenere i talk per titolo
app.post('/get_talks_by_title', (req, res) => {
    const { title, doc_per_page = 10, page = 1 } = req.body;
    if (!title) {
        return res.status(400).json({ error: 'Title is required' });
    }

    const offset = (doc_per_page * page) - doc_per_page;
    const query = `SELECT * FROM tedx_grouped WHERE title LIKE ? LIMIT ? OFFSET ?`;

    db.all(query, [`%${title}%`, doc_per_page, offset], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json(rows);
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
