_ = require('underscore')
Backbone = require('backbone')
moment = require('moment')

#### Event
# 
class Event extends Backbone.Model

  initialize: ->
    @time = moment(@get('time'))
    @timeline = @get('timeline')

  diff: ->
    @time.diff(@timeline.startDate)

  yPosition: ->
    @timeline.yPositionForTime(@time)


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
    opts.timeline = @
    @events.add new Event(opts)

  scale: ->
    @height / @duration

  yPositionForTime: (time) ->
    time = moment(time)
    diff = time.diff(@startDate)
    return ~~(diff * @scale())

  years: ->
    [@startDate.year() .. @endDate.year()]



class EventCollection extends Backbone.Collection
  model: Event


#
# Views
#

class TimePoint extends Backbone.View
  className: 'TimePoint'

  initialize: (options) ->
    @event = @model
    @parent = options.parent

  tmpl: ->
    div '.title', @event.get('title')
    div @event.time.format("YYYY MM DD")

  render: =>
    $el = @$(@el)
    $el.html CoffeeKup.render(@tmpl, {event: @event})
    $el.attr('data-time', @event.time)
    $el.attr('data-title', @event.get('title'))
    @


class Axis extends Backbone.View
  className: 'Axis'
  initialize: (opts) ->
    @timeline = opts.timeline
    for year in @timeline.years()
      mmt = moment([year])
      @$(@el).append("<div class='AxisLabel' data-time='#{mmt}'>#{year}</div>")


#### TimelineView
# Contains TimeAxis and an array of TimePoints
class TimelineView extends Backbone.View
  className: 'Timeline'

  # holds the TimePoints in this Timeline
  children: []

  initialize: (options) ->
    @timeline = @model
    @axis = new Axis({timeline: @timeline})
    for event in @timeline.events.models
      @children.push new TimePoint({model: event, parent: @})

  render: =>
    $el = @$(@el)
    $el.attr('data-startDate', @timeline.startDate)
    $el.append @axis.el
    for point in @children
      $(@el).append(point.render().el)
    @redraw()
    @

  redraw: =>
    $el = @$(@el)
    @$("[data-time]").each (i, child) =>
      child = $(child)
      time = child.data('time')
      yPos = @timeline.yPositionForTime(time)
      child.css 'top', yPos


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


