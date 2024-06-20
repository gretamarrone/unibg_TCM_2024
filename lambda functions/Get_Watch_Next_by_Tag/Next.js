const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    _id: String,
    title: String,
    url: String
}, { collection: 'tedx_related_tags' });

module.exports = mongoose.model('talk', talk_schema);