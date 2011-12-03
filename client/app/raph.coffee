models = require('models')

$ ->

  ows = new models.EventCollection()

  $.getJSON '/data/ows.json', (data) ->
    console.log data

