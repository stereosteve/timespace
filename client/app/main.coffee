_ = require('underscore')
Backbone = require('backbone')
moment = require('moment')

#### Event
class Event extends Backbone.Model

  initialize: ->
    @time = moment(@get('time'))


#### EventCollection
class EventCollection extends Backbone.Collection
  model: Event

  sorted: ->
    new EventCollection(@sortBy (event) -> event.time)

  startDate: ->
    @sorted().first().time
  
  endDate: ->
    @sorted().last().time

  duration: ->
    @endDate().diff(@startDate())


#### Views


#### EventView
class EventView extends Backbone.View
  className: 'EventView'

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

#### AxisView
class AxisView extends Backbone.View
  className: 'AxisView'

  showYears: true
  showHalfYears: true
  showMonths: false

  initialize: (opts) ->
    @timeline = opts.timeline
    @render()

  render: ->
    $el = @$(@el)
    @


#### TimelineView
class TimelineView extends Backbone.View
  className: 'TimelineView'

  initialize: (opts) ->
    @events = @collection
    @eventViews = @events.map (event) ->
      new EventView(model: event).render()
    console.log @eventViews
    @axis = new AxisView(timeline: @)
    @height = 2500

  setHeight: (height) ->
    @height = height
    @trigger('redraw')

  scale: ->
    @height / @events.duration()

  yPositionForTime: (time) =>
    time = moment(time)
    ref = @events.startDate()
    diff = time.diff(ref)
    res = ~~(diff * @scale())
    return res
  
  render: =>
    $el = @$(@el)
    $el.append @axis.render().el
    for view in @eventViews
      $el.append(view.el)
    @redraw()
    @
  
  redraw: =>
    $el = @$(@el)
    $el.css 'height', @height
    @$("[data-time]").each (i, child) =>
      child = $(child)
      time = child.data('time')
      yPos = @yPositionForTime(time)
      child.css 'top', yPos


#### Viewport
class Viewport extends Backbone.View
  className: 'Viewport'


#### Main

$ ->
  lifeOfSteve = new EventCollection
  
  lifeOfSteve.add
    title: "Graduated from the George Washington University with a B.S. in Computer Science"
    time: [2006, 5]

  lifeOfSteve.add
    title: "Steve is born"
    time: [1984, 2, 22]

  lifeOfSteve.add
    title: "Perkins family moves to Baltimore, MD"
    time: [1994, 5]

  lifeOfSteve.add
    title: "Graduated from Gilman High School"
    time: [2002, 6]


  console.log lifeOfSteve.startDate()
  console.log lifeOfSteve.endDate()
  console.log lifeOfSteve.duration()

  #viewport = new Viewport

  timeline = new TimelineView(collection: lifeOfSteve).render()
  $('body').html timeline.el


