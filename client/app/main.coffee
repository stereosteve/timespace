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
    #$(window).bind 'scroll', _.throttle(@windowScrolled, 50)
    $(window).bind 'scroll', @windowScrolled
  
  windowResized: (ev) =>
    @windowHeight = @window.height()
    @centerLine = @windowHeight / 2
    @trigger('windowResized')
  
  windowScrolled: (ev) =>
    #console.log @centerDate().format("LLLL")
    @trigger('windowScrolled')  

  # takes a Seconds diff and returns a span of pixels
  diffToPixels: (diff) =>
    #Math.floor(diff / @secondsPerPixel) 
    diff / @secondsPerPixel

  # takes a span of pixels and converts to Seconds diff
  pixelsToDiff: (pixels) =>
    #Math.floor(pixels * @secondsPerPixel)
    pixels * @secondsPerPixel


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
    @setSecondsPerPixel(diff / @windowHeight)
  
  setSecondsPerPixel: (spp) =>
    #console.log spp
    @secondsPerPixel = spp
    @trigger('rescale')

  
  totalHeight: =>
    @diffToPixels(@events.diff)
  
  viewportStartDate: =>
    @positionToTime(window.scrollY)

  centerDate: =>
    @positionToTime(window.scrollY + @centerLine)    

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


class Axis extends Backbone.View
  className: 'Axis'

  initialize: (opts) ->
    @switchboard = opts.switchboard
    @switchboard.bind('rescale', @redraw)
    @switchboard.bind('windowScrolled', @redraw)
    @render()

  render: =>
    @paper = Raphael(@el, 100, 100)
    @redraw()
    @
  
  redraw: =>
    $el = @$(@el)
    #$el.height(@switchboard.totalHeight())

    #@paper.clear()
    @paper.clear()
    @paper.setSize($el.width(), $el.height())

    # Draw Years
    @drawYears()
    @drawMonths()

    top = @switchboard.centerDate()
    text = @paper.text(150, $el.height()/2, top.format("LL"))
    text.attr('text-anchor', 'end')
    
  drawYears: =>
    top = @switchboard.viewportStartDate()
    mmt = top.clone().seconds(0).minutes(0).hours(0).date(1).month(0)
    point = 0
    while point < @switchboard.windowHeight
      diff = mmt.diff(top)
      point = @switchboard.diffToPixels(diff)
      path = @paper.path("M0,#{point} H80")
      path.attr('stroke-width', 2)
      text = @paper.text(1, point+5, mmt.format('YYYY'))
      text.attr('text-anchor', 'start')
      mmt.add('years', 1)
  
  drawMonths: =>
    top = @switchboard.viewportStartDate()
    mmt = top.clone().seconds(0).minutes(0).hours(0).date(1)
    point = 0
    while point < @switchboard.windowHeight
      unless mmt.month() == 0
        diff = mmt.diff(top)
        point = @switchboard.diffToPixels(diff)
        path = @paper.path("M0,#{point} H40")
        path.attr('stroke-width', 2)
        text = @paper.text(1, point+5, mmt.format('MMM'))
        text.attr('text-anchor', 'start')
      mmt.add('months', 1)


class Controls extends Backbone.View
  className: 'RaphControls'

  initialize: (opts) ->
    @switchboard = opts.switchboard
    @render()

  tmpl: ->
    div '.slider', ''
    ul ->
      li '.century', 'Century'
      li '.decade', 'Decade'
      li '.years', 'Year'
      li '.months', 'Month'
      li '.weeks', 'Week'
      li '.days', 'Day'
      li '.hours', 'Hour'
      li '.minutes', 'Minute'
  
  events:
    "click li": "setScale"
  
  setScale: (ev) ->
    unit = $(ev.target).attr('class')
    if unit is 'century'
      diff = diffFor('years', 100)
    else if unit is 'decade'
      diff = diffFor('years', 10)
    else
      diff = diffFor(unit, 2)

    @switchboard.setScreenDiff(diff)
    console.log @switchboard.secondsPerPixel
    #@$('.slider').slider('value', @switchboard.spp)

  render: =>
    @$(@el).html CoffeeKup.render(@tmpl)
    @$('.slider').slider
      max: 30
      step: 0.01
      slide: (e, ui) =>
        v = Math.floor(Math.exp(ui.value))
        console.log v
        @switchboard.setSecondsPerPixel(v)
    @

#### TimelineView
class TimelineView extends Backbone.View
  className: 'TimelineView'

  initialize: (opts) ->
    @switchboard = opts.switchboard
    @switchboard.bind('rescale', @redraw)
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
    @$(@el).height( @switchboard.totalHeight() )

    # TODO: move this to TimeGeometry?
    - if true
      @$(".EventView").each (i, child) =>
        child = $(child)
        time = child.data('time')
        yPos = @switchboard.timeToPosition(time)
        child.css 'top', yPos
    


#### Timespace

class Timespace extends Backbone.View
  className: "Timespace"
  
  initialize: (events) ->
    @events = events
    @switchboard = new Switchboard(events: events)
    @timeline = new TimelineView(switchboard: @switchboard)
    @axis = new Axis(switchboard: @switchboard)
    @controls = new Controls(switchboard: @switchboard)
  
  render: =>
    $el = @$(@el)
    $el.append("<div class='CenterLine' />")
    $el.append(@timeline.render().el)
    $el.append(@axis.render().el)
    $el.append(@controls.render().el)
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
    title: "Y2K"
    time: [2000, 0]

  lifeOfSteve.add
    title: "Graduated from Gilman High School"
    time: [2002, 5]

  window.timespace = new Timespace(events: lifeOfSteve)
  $('body').html timespace.el
  timespace.render()

  
  #switchboard = new Switchboard(events: lifeOfSteve)
  #switchboard.setScreenDiff( diffFor('years', 2) )
  #console.log switchboard.secondsPerPixel

