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

  setHeight: (height) ->
    @height = height
    @trigger('redraw')

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

  showYears: true
  showHalfYears: true
  showMonths: false

  initialize: (opts) ->
    @timeline = opts.timeline
    @render()

  render: ->
    $el = @$(@el)
    if @showYears
      mmt = moment(@timeline.startDate)
      while mmt < @timeline.endDate
        $el.append("<div class='AxisLabel year' data-time='#{mmt}'>#{mmt.year()}</div>")
        mmt.add('years', 1)

    if @showHalfYears
      mmt = moment([@timeline.startDate.year(), 6])
      while mmt < @timeline.endDate
        $el.append("<div class='AxisLabel halfYear' data-time='#{mmt}'>#{mmt.format('MMMM')}</div>")
        mmt.add('years', 1)


    if @showMonths
      mmt = moment(@timeline.startDate)
      while mmt < @timeline.endDate
        unless mmt.month() == 0
          $el.append("<div class='AxisLabel month' data-time='#{mmt}'>#{mmt.format('MMMM')}</div>")
        mmt.add('months', 1)
    @



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
    @timeline.bind('redraw', @redraw)

  tmpl: ->
    div '.controls', ->
      div '.currentScale', 0
      div '.scale-slider', ''
      ul '.scaleTo', ->
        li '.century', 'Century'
        li '.decade', 'Decade'
        li '.year', 'Year'
        li '.month', 'Month'
        li '.week', 'Week'
        li '.day', 'Day'

  events:
    'click .scaleTo': 'changeScale'

  changeScale: (ev) ->
    to = $(ev.target).attr('class')
    debugger
    if to == 'decade'
      @timeline.setHeight(1850)
    else if to == 'year'
      @timeline.setHeight(10000)

  render: =>
    $el = @$(@el)
    $el.html CoffeeKup.render(@tmpl)
    @$(".scale-slider").slider
      min: 100
      max: 10000
      slide: (e, ui) => @timeline.setHeight(ui.value)
    $el.attr('data-startDate', @timeline.startDate)
    $el.append @axis.el
    for point in @children
      $(@el).append(point.render().el)
    @redraw()
    @

  redraw: =>
    $el = @$(@el)
    $el.css 'height', @timeline.height
    @$('.currentScale').text @timeline.height
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


