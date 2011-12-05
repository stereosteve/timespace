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

  if false
    $.getJSON '/data/tweets.json', (data) ->
      _.each data.results, (tweet) ->
        events.add({
          time: tweet.created_at
          title: tweet.text
        })
      go()

  if false
    $.getJSON '/data/votes.json', (data) ->
      _.each data.results.votes, (vote) ->
        events.add({
          mmt: moment("#{vote.date} #{vote.time}", "YYYY-M-DD HH:mm:ss")
          title: vote.question
        })
      go()

  if true
    $.getJSON 'http://api.twitter.com/1/trends/daily.json?callback=?', (data) ->
      _.each data.trends, (trends, date) ->
        _.each trends, (trend) ->
          events.add({
            mmt: date
            title: trend.name
          })
      go()

