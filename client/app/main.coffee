Backbone = require('backbone')
moment = require('moment')

class TimeGrid extends Backbone.View

  className: 'TimeGrid'

  tmpl: ->
    div '.line', ' '
    p @startDate.format("YYYY")

  render: =>
    console.log @options.startDate
    @$(@el).html CoffeeKup.render(@tmpl, {startDate: @options.startDate})
    @


$ ->
  tg = new TimeGrid({startDate: moment([1983]), endDate: moment([2012])})
  tg.render()

  $('body').html tg.el
