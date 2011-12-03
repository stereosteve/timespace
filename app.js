
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
    __dirname + '/public/vendor/js/coffeekup.js'
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

app.get('/tweets/:term', function(req, res) {
  request('http://search.twitter.com/search.json?q=ows', function(err, response, body) {
    res.contentType('application/json')
    res.send(body)
  })
})

var NYT_API = {
  articles: "6f4df6b8dcd31f03e051bfdebb7669fb:3:54084143",
  congress: "9ce7bf6137aeae49417f8a2dc47ad17b:1:54084143",
  events: "6efda9578e5bec151e48846272e6de2b:13:54084143"
}

app.get('/articles', function(req, res) {
  r = 'http://api.nytimes.com/svc/search/v1/article.json?api-key='+NYT_API.articles
  request(r, function(err, response, body) {
    res.contentType('application/json')
    res.send(body)
  })
})

app.get('/votes', function(req, res) {
  r = 'http://api.nytimes.com/svc/politics/v3/us/legislative/congress/house/votes/2011/02.json?api-key='+NYT_API.congress
  request(r, function(err, response, body) {
    res.contentType('application/json')
    res.send(body)
  })
})

app.get('/events', function(req, res) {
  r = 'http://api.nytimes.com/svc/events/v2/listings.json?filters=category:forChildren&api-key='+NYT_API.events
  request(r, function(err, response, body) {
    res.contentType('application/json')
    res.send(body)
  })
})

app.listen(3000);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
