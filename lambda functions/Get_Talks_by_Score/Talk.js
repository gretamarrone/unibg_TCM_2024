const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    id: String,
    title: String,
    url: String
}, { collection: 'tf-idf' });

module.exports = mongoose.model('talk', talk_schema);