
var express = require('express')
  , routes = require('./routes')
  , stylus = require('stylus')
  , stitch = require('stitch')

var app = module.exports = express.createServer();

// Stitch javascript package
var stitchPackage = stitch.createPackage({
  paths: [
    'assets/javascripts',
    'assets/vendor'
  ]
})


// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);

  app.use(stylus.middleware({
      src: __dirname + '/assets' 
    , dest: __dirname + '/public' 
    , compile: function(str, path) {
                  return stylus(str)
                  .set('filename', path)
                  .set('warn', true)
                  .set('compress', true);
                }
  }));

  app.get('/app.js', stitchPackage.createServer());

  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

// Routes

app.get('/', routes.index);

app.listen(3000);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
