const mongoose = require('mongoose');

const watch_next_schema = new mongoose.Schema({
    _id: String,
    url: String,
    title: String
});

const talk_schema = new mongoose.Schema({
    _id: String,
    watch_next: [watch_next_schema]
}, { collection: 'tf_idf' });
module.exports = mongoose.model('talk', talk_schema);