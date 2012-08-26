#!/usr/bin/env node

/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , path = require('path');

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  // app.use(express.static(path.join(__dirname, 'public')));
  app.use(require("connect-assets")({ src: __dirname + "/assets", buildDir: __dirname + "cache/assets" }));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});


app.get('/', function(req, res){
  res.render('index', { title: 'Express' });
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
