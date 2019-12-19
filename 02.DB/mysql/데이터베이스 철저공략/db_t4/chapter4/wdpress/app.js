
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , user = require('./routes/user')
  , http = require('http')
  , path = require('path');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);

var server = http.createServer(app);
server.listen(app.get('port'));

var io = require('socket.io').listen(server);
var model = require('./model');

io.sockets.on('connection',function(socket){
  console.log('Socket.IO session connected');
  socket.on('save',function(msg){
    model.User.update(
      {userId: msg.userId}, msg, {upsert: true},
      function(err){ if(err) console.log(err); }
    );
  });
});
