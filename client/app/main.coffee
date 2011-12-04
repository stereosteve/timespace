moment.fn.floor = (unit) ->
  units = ['seconds', 'minutes', 'hours', 'date', 'months']
  i = units.indexOf(unit)
  if i > -1
    @seconds(0)
  if i > 0
    @minutes(0)
  if i > 1
    @hours(0)
  if i > 2
    @date(1)
  if i > 3
    @month(0)
  @

window.SECONDS_FOR = 
  minute: 60
  hour: 3600
  day: 84600
  week: 604800
  month: 2629743.83
  year: 31556926

################################################################
# Models

#### Event
class Event extends Backbone.Model

  initialize: ->
    @setMmt()
    
  
  setMmt: =>
    if @get('mmt')
      @mmt = moment(@get('mmt'))
    else if @get('date')
      @mmt = moment(@get('date'))
    else if @get('time')
      @mmt = moment(@get('time'))
    else if @get('created_at')
      @mmt = moment(@get('created_at'))
    else
      console.log "no moment"
      @mmt = moment()




#### EventCollection
class EventCollection extends Backbone.Collection
  model: Event

  initialize: ->
    #@bind('add', @changed)
    #@bind('reset', @changed)

  prepare: =>
    @startDate = @sorted().first().mmt
    @endDate = @sorted().last().mmt
    @diff = @endDate.diff(@startDate)

  sorted: ->
    new EventCollection(@sortBy (event) -> event.mmt)
  
  between: (start, end) ->
    new EventCollection(@filter (event) -> 
      event.mmt > start and event.mmt < end)
  
  groupByDate: ->
    groups = {}
    @each (event) ->
      key = event.mmt.clone().floor('hours')
      groups[key.valueOf()] ||= []
      groups[key.valueOf()].push(event)
    groups
      



################################################################
# Views

#### EventView
class EventView extends Backbone.View
  className: 'Temporal EventView'

  initialize: (options) ->
    @event = @model

  tmpl: ->
    div '.title', @event.get('title')
    div @event.mmt.format("LLLL")

  render: =>
    $el = @$(@el)
    $el.html CoffeeKup.render(@tmpl, {event: @event})
    $el.attr('data-mmt', @event.mmt)
    @



## Group View
class EventTile extends Backbone.View
  className: 'EventTile'
  render: =>
    @$(@el).text(@model.get('title'))
    @

class GroupView extends Backbone.View
  className: 'Temporal GroupView'

  initialize: (opts) ->
    @mmt = opts.mmt
    @events = opts.events

  render: =>
    $el = @$(@el)
    $el.attr('data-mmt', @mmt)
    for event in @events
      console.log event
      $el.append new EventTile(model: event).render().el
    @


##

class ControlsView extends Backbone.View
  
  className: 'controls'

  initialize: (opts) ->
    @timeline = opts.timeline

  tmpl: ->
    div '.CenterDate', 'center date'
    select '.grouping', ->
      option value: 'Minute', 'Minute'
      option value: 'HalfHour', 'Half Hour'
      option value: 'Hour', 'Hour'
      option value: 'HalfDay', 'Half Day'
      option value: 'Day', 'Day'
      option value: 'Week', 'Week'
      option value: 'Month', 'Month'
      option value: 'QuarterYear', 'Quarter Year'
      option value: 'HalfYear', 'Half Year'
      option value: 'Year', 'Year'

    button '.button.zoomout', '-'
    button '.button.zoomin', '+'
  
  events:
    'click .zoomout': 'zoomout'
    'click .zoomin': 'zoomin'
    'change .grouping': 'regroup'

  regroup: =>
    grouping = @$('.grouping').val()
    console.log grouping

  zoomout: =>
    @timeline.setSPP( @timeline.secondsPerPixel * 1.5 )
  
  zoomin: =>
    @timeline.setSPP( @timeline.secondsPerPixel / 1.5 )

  render: =>
    @$(@el).html CoffeeKup.render(@tmpl)
    @



#### AxisView
class AxisView extends Backbone.View
  className: 'AxisView'

  initialize: (opts) ->
    @e = @$(@el)
    @timeline = opts.timeline
    @ticks = {}
  
  dayTicks: (show) =>
    if show is true and not @ticks['Days']
      @ticks["Days"] = true
      h = @startDate.clone().floor('hours').add('days', 1)
      while h < @endDate
        @e.append("<div class='Temporal DayMarker' data-mmt='#{h}'>#{h.format('MM/DD')}</div>")
        h.add('days', 1)
    
    if show is false and @ticks['Days']
      @$('.DayMarker').remove()
      @ticks["Days"] = false
  
  hourTicks: (show) =>

    # show hours
    if show is true and not @ticks['Hour']
      @ticks["Hour"] = true
      h = @startDate.clone().floor('minutes').add('hours', 1)
      while h < @endDate
        unless h.hours() == 0
          @e.append("<div class='Temporal HourMarker' data-mmt='#{h}'>#{h.format('HH:mm')}</div>")
        h.add('hours', 1)
    
    # hide hours
    if show is false and @ticks['Hour']
      @$('.HourMarker').remove()
      @ticks["Hour"] = false

  halfHourTicks: (show) =>

    # show half hour
    if show is true and not @ticks['HalfHour']
      @ticks["HalfHour"] = true
      h = @startDate.clone().seconds(0).minutes(30).add('hours', 1)
      while h < @endDate
        @e.append("<div class='Temporal HalfHourMarker' data-mmt='#{h}'>#{h.format('HH:mm')}</div>")
        h.add('hours', 1)

    # hide half hour
    if show is false and @ticks['HalfHour']
      @$('.HalfHourMarker').remove()
      @ticks["HalfHour"] = false

  
  render: =>
    @startDate = @timeline.events.startDate
    @endDate = @timeline.events.endDate
    spp = @timeline.secondsPerPixel

    # days
    @dayTicks(true)

    # hours
    if spp < 250000
      @hourTicks(true)
    else
      @hourTicks(false)
    
    # half hours
    if spp < 110000
      @halfHourTicks(true)
    else
      @halfHourTicks(false)
      
    @


#### TimelineView
class TimelineView extends Backbone.View
  className: 'TimelineView'

  initialize: (opts) ->
    @e = @$(@el)
    @secondsPerPixel = opts.secondsPerPixel || 1000000
    @events = opts.events
    @groups = opts.groups

    @axis = new AxisView(timeline: @)
    @controls = new ControlsView(timeline: @)
    

  render: =>
    @startDate = @events.startDate
    @endDate = @events.endDate

    @e.attr 'data-mmt', @startDate

    #@events.each (event) =>
    #  view = new EventView(model: event)
    #  @e.append(view.render().el)

    for mmt in _.keys(@groups)
      ev = @groups[mmt]
      groupView = new GroupView(mmt: mmt, events: ev)
      @e.append(groupView.render().el)

    @e.append @axis.render().el
    @e.append @controls.render().el
    @redraw()

    @windowScroll()
    $(window).scroll @windowScroll
  
  windowScroll: (ev) =>
    m = @windowCenterDate()
    @$('.CenterDate').text(m.format('LLLL'))
  
  windowCenterDate: (d) =>
    $w = $(window)
    if d
      diff = moment(d).diff(@startDate)
      pixel = diff / @secondsPerPixel
      $w.scrollTop(pixel - $w.height()/2)
    else
      d = $w.scrollTop() + $w.height()/2
      m = moment( @startDate + d * @secondsPerPixel )
  
  setSPP: (spp) =>
    before = @windowCenterDate()
    @secondsPerPixel = spp
    @axis.render()
    @redraw()
    @windowCenterDate(before)
  
  mmtToPixel: (mmt) =>
    diff = moment(mmt).diff(@events.startDate) 
    console.log diff
    diff / @secondsPerPixel

  redraw: =>
    window.spp = @secondsPerPixel
    @e.height( @events.diff / @secondsPerPixel )
    $(".Temporal").each (i, child) =>
      child = $(child)
      mmt = moment(child.data('mmt'))
      yPos = mmt.diff(@events.startDate) / @secondsPerPixel
      child.css 'top', yPos
    $(".GroupView").height( moment().diff(moment().subtract('days', 1)) / @secondsPerPixel )
    @

  

################################################################
# Main

$ ->
  
  window.events = new EventCollection()
  window.timeline = new TimelineView(events: events)
  $('body').append timeline.el

  finished = 0
  finish = =>
    finished += 1
    if finished == 2
      events.prepare()
      groups = events.groupByDate()

      timeline.groups = groups
      timeline.render()
        
      #timeline.redraw()


  $.getJSON '/data/tweets.json', (data) ->
    _.each data.results, (tweet) ->
      events.add({
        time: tweet.created_at
        title: tweet.text
      })
    finish()

  $.getJSON '/data/votes.json', (data) ->
    _.each data.results.votes, (vote) ->
      events.add({
        mmt: moment("#{vote.date} #{vote.time}", "YYYY-MM-DD HH:mm:ss")
        title: vote.question
      })
    finish()
    
  moment().floor('hours')

