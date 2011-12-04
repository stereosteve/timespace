
var express = require('express')
  , stylus = require('stylus')
  , stitch = require('stitch')
  , request = require('request')

var stitchPackage = stitch.createPackage({
  paths: [
    __dirname + '/client/app'
  ],
  dependencies: [
    __dirname + '/public/vendor/js/jquery.js',
    __dirname + '/public/vendor/js/underscore.js',
    __dirname + '/public/vendor/js/backbone.js',
    __dirname + '/public/vendor/js/moment.js',
    __dirname + '/public/vendor/js/jqueryui.js',
    __dirname + '/public/vendor/js/coffeekup.js',
    __dirname + '/public/vendor/js/waypoints.js',
    __dirname + '/public/vendor/js/jquery.scrollTo.js'
  ]
})



var app = module.exports = express.createServer();


// Configuration

app.configure(function(){
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);

  app.use(stylus.middleware({
      src: __dirname + '/client' 
    , dest: __dirname + '/public' 
    , compile: function(str, path) {
                  return stylus(str)
                  .set('filename', path)
                  .set('warn', true)
                  .set('compress', true);
                }
  }));

  app.get('/client.js', stitchPackage.createServer());

  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

// Routes
//app.get('/', routes.index);



app.listen(3000);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
