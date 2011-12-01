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

  initialize: (options) ->
    @parent = options.parent

  tmpl: ->
    div '.title', @event.get('title')

  render: =>
    @$(@el).html CoffeeKup.render(@tmpl, {event: @model})
    @$(@el).css 'top', @model.get('time').year()
    @

  redraw: =>
    diff = @model.get('time').diff(@parent.startDate)
    y = ~~((diff / @parent.duration) * @parent.height)
    @$(@el).css 'top', y
    console.log y

#### TimeAxis
# The ruler on the left hand side
class views.TimeAxis extends Backbone.View
  className: 'TimeAxis'

  initialize: (options) ->
    @parent = options.parent

  render: =>
    @


#### TimeGrid
# Contains TimeAxis and an array of TimePoints
class views.TimeGrid extends Backbone.View
  className: 'TimeGrid'

  # holds the TimePoints in this TimeGrid
  children: []

  initialize: (options) ->

    @startDate = options.startDate
    @endDate = options.endDate

    @axis = new views.TimeAxis({parent: @}).render()

    for event in @collection.models
      @children.push new views.TimePoint({model: event, parent: @})

    console.log @children
    
  tmpl: ->

  render: =>
    console.log @options.startDate
    @$(@el).html CoffeeKup.render(@tmpl, {startDate: @options.startDate, collection: @collection})
    @$(@el).append @axis.el
    for point in @children
      $(@el).append(point.render().el)
    @

  redraw: =>
    @height = @$(@el).height()
    @duration = @endDate.diff(@startDate)
    console.log @duration
    for point in @children
      point.redraw()


$ ->

  window.lifeOfSteve = new collections.Events
  lifeOfSteve.add( new models.Event({title: "Steve is born", time: moment([1984, 2, 22])}) )
  lifeOfSteve.add( new models.Event({title: "Steve moves to baltimore", time: moment([1994, 5])}) )
  lifeOfSteve.add( new models.Event({title: "Graduates from Gilman high school", time: moment([2002, 6])}) )
  lifeOfSteve.add( new models.Event({title: "Graduates from the George Washington University", time: moment([2006, 6])}) )

  steveTimeline = new views.TimeGrid({startDate: moment([1983]), endDate: moment([2012]), collection: lifeOfSteve})
  steveTimeline.render()
  $('body').html steveTimeline.el
  steveTimeline.redraw()
