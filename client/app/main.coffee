Backbone = require('backbone')
moment = require('moment')

models = {}
collections = {}
views = {}

#
# Models
#

class models.Event extends Backbone.Model

class collections.Events extends Backbone.Collection
  model: models.Event


#
# Views
#

class views.TimePoint extends Backbone.View
  className: 'TimePoint'

  render: =>
    @$(@el).css 'top', @model.get('time').year()
    @



class views.TimeGrid extends Backbone.View
  className: 'TimeGrid'

  # holds the TimePoints in this TimeGrid
  children: []

  initialize: ->
    for event in @collection.models
      @children.push new views.TimePoint({model: event, parent: @})
    console.log @children
    
  tmpl: ->
    div '.line', ' '
    p @startDate.format("YYYY")
    p @collection.length
    for event in @collection.models
      p -> event.get('title')

  render: =>
    console.log @options.startDate
    @$(@el).html CoffeeKup.render(@tmpl, {startDate: @options.startDate, collection: @collection})
    @redraw()
    @

  redraw: =>
    for timePoint in @children
      console.log timePoint
      $(@el).append(timePoint.render().el)


$ ->

  window.lifeOfSteve = new collections.Events
  lifeOfSteve.add( new models.Event({title: "Steve is born", time: moment([1984, 2, 22])}) )
  lifeOfSteve.add( new models.Event({title: "Steve moves to baltimore", time: moment([1994, 5])}) )

  steveTimeline = new views.TimeGrid({startDate: moment([1983]), endDate: moment([2012]), collection: lifeOfSteve})
  steveTimeline.render()
  $('body').html steveTimeline.el
