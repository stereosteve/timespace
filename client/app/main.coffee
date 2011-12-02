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

####
#### Views
####

#### EventView
class EventView extends Backbone.View
  className: 'EventView'

  initialize: (options) ->
    @event = @model
    @parent = options.parent

  tmpl: ->
    div '.title', @event.get('title')
    div @event.time.format("MMMM YYYY")

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


  
  # takes a Seconds diff and returns a span of pixels
  diffToPixels: (diff) =>
    Math.floor(diff * @scale())  

  # takes a span of pixels and converts to Seconds diff
  pixelsToDiff: (pixels) =>
    Math.floor(pixels / @height * @events.duration())


  # takes a absolute time and returns the position
  timeToPosition: (time) =>
    time = moment(time)
    @diffToPixels(time.diff(@events.startDate()))
  
  # takes a y coordinate and returns the time
  positionToTime: (y) =>
    diff = @pixelsToDiff(y)
    moment(@events.startDate() + diff)
  

  # takes a diff in seconds and returns in minutes, hours, days, weeks, etc
  convertDiff: (d, output) =>
    now = moment()
    moment(now+d).diff(now, output)

  
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
      yPos = @timeToPosition(time)
      child.css 'top', yPos


#### Viewport
#class Viewport extends Backbone.View
#  className: 'Viewport'


#### Main

$ ->
  lifeOfSteve = new EventCollection
  
  lifeOfSteve.add
    title: "Graduated from the George Washington University with a B.S. in Computer Science"
    time: [2006, 4]

  lifeOfSteve.add
    title: "Steve is born"
    time: [1984, 1, 22]

  lifeOfSteve.add
    title: "Perkins family moves to Baltimore, MD"
    time: [1994, 4]

  lifeOfSteve.add
    title: "Graduated from Gilman High School"
    time: [2002, 5]

  window.timeline = new TimelineView(collection: lifeOfSteve).render()
  $('body').html timeline.el



  # Junk
  gilman = lifeOfSteve.sorted().at(2)
  gw = lifeOfSteve.sorted().at(3)
  diff = gw.time.diff(gilman.time)

  console.log "ticks"
  screenDiff = timeline.pixelsToDiff($(window).height())
  console.log timeline.convertDiff(screenDiff, 'years')


  $(window).scroll (ev) ->
    pos = $(window).scrollTop()
    topDate = timeline.positionToTime(pos)
    #console.log topDate.format("LL")




