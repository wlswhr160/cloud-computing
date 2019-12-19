var mongoose = require('mongoose');

var url = 'mongodb://localhost:27017/wdpress';
var db = mongoose.connect(url);
db.connection.on('connected',function(){
  console.log('MongoDB connected.');
});

var User = new mongoose.Schema({
  userId : { type: String, unique: true },
  age : Number,
  site : { name: String, url: String }
});
exports.User = db.model('users', User);

