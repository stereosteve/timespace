require('moment_ext')
Event = require('models').Event
EventCollection = require('models').EventCollection
Viewport = require('views').Viewport

$ ->
  window.events = new EventCollection()
  window.viewport = new Viewport(collection: events)


  go = ->
    console.log events.mean().mmt
    viewport.render()

  $.getJSON '/data/votes.json', (data) ->
    _.each data.results.votes, (vote) ->
      events.add({
        mmt: moment("#{vote.date} #{vote.time}", "YYYY-M-DD HH:mm:ss")
        title: vote.question
      })
    go()
