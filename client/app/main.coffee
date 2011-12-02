_ = require('underscore')
Backbone = require('backbone')
moment = require('moment')

# takes a diff in seconds and returns in minutes, hours, days, weeks, etc
convertSeconds = (seconds, output) ->
  now = moment()
  moment(now+seconds).diff(now, output)

#class Span
#  initialize: (seconds) ->
#    @seconds = seconds
  

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

  initialize: (opts) ->
    @timeline = opts.timeline
    @render()
  
  drawLabels: (unit, format) =>
    mmt = moment([@timeline.startDate().year()])
    while mmt < @timeline.endDate()
      @$(@el).append("<div class='AxisLabel #{unit}' data-time='#{mmt}'>#{mmt.format(format)}</div>")
      mmt.add(unit, 1)

  render: =>
    $el = @$(@el)
    
    @drawLabels('years', 'YYYY')
    #@drawLabels('months', 'MMMM')

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


  startDate: ->
    @events.startDate()
  
  endDate: ->
    @events.endDate()
  
  duration: ->
    @events.duration()
  
  # takes a Seconds diff and returns a span of pixels
  diffToPixels: (diff) =>
    Math.floor(diff * @scale())  

  # takes a span of pixels and converts to Seconds diff
  pixelsToDiff: (pixels) =>
    Math.floor(pixels / @height * @duration())


  # takes a absolute time and returns the position
  timeToPosition: (time) =>
    time = moment(time)
    @diffToPixels(time.diff(@startDate()))
  
  # takes a y coordinate and returns the time
  positionToTime: (y) =>
    diff = @pixelsToDiff(y)
    moment(@startDate() + diff)
  
  
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
  console.log convertSeconds(screenDiff, 'years')


  $(window).scroll (ev) ->
    pos = $(window).scrollTop()
    topDate = timeline.positionToTime(pos)
    #console.log topDate.format("LL")




