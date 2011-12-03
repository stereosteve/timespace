var request = require('request')
var util = require('util')

request('http://search.twitter.com/search.json?q=ows', function(err, response, body) {
  util.debug(body)
})
