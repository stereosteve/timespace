_ = require('underscore')
Backbone = require('backbone')
moment = require('moment')

#### Event
# 
class Event extends Backbone.Model

  initialize: ->
    @time = moment(@get('time'))

#### Timeline
# Holds the events and does all the date math
class Timeline extends Backbone.Model

  initialize: ->
    @events = new EventCollection
    @startDate = moment(@get('startDate'))
    @endDate = moment(@get('endDate'))
    @duration = @endDate.diff(@startDate)
    @height = 2500

  addEvent: (opts) ->
    @events.add new Event(opts)

  positionFor: (time) ->
    diff = time.diff(@startDate)
    return ~~((diff / @duration) * @height)




class EventCollection extends Backbone.Collection
  model: Event


#
# Views
#

class TimePoint extends Backbone.View
  className: 'TimePoint'

  initialize: (options) ->
    @parent = options.parent

  tmpl: ->
    div '.title', @event.get('title')

  setY: (y) ->
    @$(@el).css 'top', y

  render: =>
    @$(@el).html CoffeeKup.render(@tmpl, {event: @model})
    @

#### TimeAxis
# The ruler on the left hand side
class TimeAxis extends Backbone.View
  className: 'TimeAxis'

  initialize: (options) ->
    @parent = options.parent

  render: =>
    @


#### TimelineView
# Contains TimeAxis and an array of TimePoints
class TimelineView extends Backbone.View
  className: 'Timeline'

  # holds the TimePoints in this Timeline
  children: []

  initialize: (options) ->
    @axis = new TimeAxis({parent: @}).render()
    for event in @model.events.models
      @children.push new TimePoint({model: event, parent: @})
    
  tmpl: ->

  render: =>
    @$(@el).html CoffeeKup.render(@tmpl, {})
    @$(@el).append @axis.el
    for point in @children
      $(@el).append(point.render().el)
      point.setY( @model.positionFor(point.model.time) )
    @


$ ->

  window.lifeOfSteve = new Timeline
    startDate: [1984]
    endDate: [2012]

  lifeOfSteve.addEvent
    title: "Steve is born"
    time: [1984, 2, 22]

  lifeOfSteve.addEvent
    title: "Perkins family moves to Baltimore, MD"
    time: [1994, 5]

  lifeOfSteve.addEvent
    title: "Graduated from Gilman High School"
    time: [2002, 6]

  lifeOfSteve.addEvent
    title: "Graduated from the George Washington University with a B.S. in Computer Science"
    time: [2006, 5]

  steveTimeline = new TimelineView({model: lifeOfSteve})
  steveTimeline.render()
  $('body').html steveTimeline.el

