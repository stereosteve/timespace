_ = require('underscore')
Backbone = require('backbone')
moment = require('moment')

#
# Helpers
#

# takes a diff in seconds and returns in minutes, hours, days, weeks, etc
convertDiff = (seconds, output) ->
  now = moment()
  moment(now+seconds).diff(now, output)

# takes ('months', 3) and converts to a diff
diffFor = (unit, value) ->
  now = moment()
  next = now.clone().add(unit, value)
  next.diff(now)


#
# Models
#

#### Event
class Event extends Backbone.Model

  initialize: ->
    @time = moment(@get('time'))



#
# Collections
#

#### EventCollection
class EventCollection extends Backbone.Collection
  model: Event

  initialize: ->
    @bind('add', @changed)

  changed: =>
    @startDate = @sorted().first().time
    @endDate = @sorted().last().time
    @diff = @endDate.diff(@startDate)

  sorted: ->
    new EventCollection(@sortBy (event) -> event.time)



#
# Mission Control
#

#### Switchboard
class Switchboard extends Backbone.Model

  initialize: ->
    @secondsPerPixel = 100000000
    @events = @get('events').events

    # store wrapped window object
    @window = $(window)
    @windowResized()
    $(window).bind 'resize', @windowResized
  
  windowResized: (ev) =>
    @windowHeight = @window.height()
    @centerLine = @windowHeight / 2
    @trigger('windowResized')

  # takes a Seconds diff and returns a span of pixels
  diffToPixels: (diff) =>
    ~~ (diff / @secondsPerPixel) 

  # takes a span of pixels and converts to Seconds diff
  pixelsToDiff: (pixels) =>
    Math.floor(pixels * @secondsPerPixel)


  # takes a absolute time and returns the position
  timeToPosition: (time) =>
    time = moment(time)
    @diffToPixels(time.diff(@events.startDate))
  
  # takes a y coordinate and returns the time
  positionToTime: (y) =>
    diff = @pixelsToDiff(y)
    moment(@events.startDate + diff)
  
  # returns the diff for the screen hieght - ie how many seconds are showing
  # pass 'years, months, weeks, days' if you dont want seconds
  screenDiff: (unit) =>
    d = @pixelsToDiff(@windowHeight)
    d = convertDiff(d, unit) if unit?
    d

  setScreenDiff: (diff) =>
    @secondsPerPixel = Math.floor(diff / @windowHeight)
    #@redraw()



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





#### TimelineView
class TimelineView extends Backbone.View
  className: 'TimelineView'

  initialize: (opts) ->
    @switchboard = opts.switchboard
    @events = @switchboard.events
    @eventViews = @events.map (event) ->
      new EventView(model: event).render()


  render: =>
    $el = @$(@el)
    for view in @eventViews
      $el.append(view.el)
    @redraw()
    @
  
  redraw: =>
    @$(@el).height( @switchboard.diffToPixels(@switchboard.events.diff))

    # TODO: move this to TimeGeometry?
    - if true
      @$(".EventView").each (i, child) =>
        child = $(child)
        time = child.data('time')
        yPos = @switchboard.timeToPosition(time)
        child.css 'top', yPos
    


#### Timespace

class Timespace extends Backbone.View
  
  initialize: (events) ->
    @events = events
    @switchboard = new Switchboard(events: events)
    @timeline = new TimelineView(switchboard: @switchboard)
  
  render: =>
    @$(@el).append(@timeline.render().el)
    @


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

  window.timespace = new Timespace(events: lifeOfSteve)
  $('body').html timespace.el
  timespace.render()

  
  switchboard = new Switchboard(events: lifeOfSteve)
  switchboard.setScreenDiff( diffFor('years', 2) )
  #console.log switchboard.secondsPerPixel

