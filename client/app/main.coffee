################################################################
# Models

#### Event
class Event extends Backbone.Model

  initialize: ->
    @setMmt()
    
  
  setMmt: =>
    if @get('date') and @get('time')
      @mmt = moment(@get('date') + ' ' + @get('time'))
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



################################################################
# Views

#### EventView
class EventView extends Backbone.View
  className: 'Temporal EventView'

  initialize: (options) ->
    @event = @model
    @parent = options.parent

  tmpl: ->
    div '.title', @event.get('title')
    div @event.mmt.format("LLLL")

  render: =>
    $el = @$(@el)
    $el.html CoffeeKup.render(@tmpl, {event: @event})
    $el.attr('data-mmt', @event.mmt)
    @


class ControlsView extends Backbone.View
  
  className: 'controls'

  initialize: (opts) ->
    @timeline = opts.timeline

  tmpl: ->
    div '.button.zoomout', '-'
    div '.button.zoomin', '+'
  
  events:
    'click .zoomout': 'zoomout'
    'click .zoomin': 'zoomin'

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
      h = @startDate.clone().seconds(0).minutes(0).hours(0).add('days', 1)
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
      h = @startDate.clone().seconds(0).minutes(0).add('hours', 1)
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
    @secondsPerPixel = opts.secondsPerPixel || 10000
    @events = opts.events
    #@events.bind('all', @render)

    @axis = new AxisView(timeline: @)
    @controls = new ControlsView(timeline: @)
    

  render: =>
    @e.attr 'data-mmt', @events.startDate
    @events.each (event) =>
      view = new EventView(model: event)
      @e.append(view.render().el)
    @e.append @axis.render().el
    @e.append @controls.render().el
    @redraw()
  
  setSPP: (spp) ->
    @secondsPerPixel = spp
    console.log spp
    @axis.render()
    @redraw()

  redraw: =>
    @e.height( @events.diff / @secondsPerPixel )
    $(".Temporal").each (i, child) =>
      child = $(child)
      mmt = moment(child.data('mmt'))
      yPos = mmt.diff(@events.startDate) / @secondsPerPixel
      child.css 'top', yPos
    @

  

################################################################
# Main

$ ->
  
  window.events = new EventCollection()
  window.timeline = new TimelineView(events: events)
  $('body').append timeline.el
  

  $.getJSON '/data/votes.json', (data) ->

    _.each data.results.votes, (vote) ->
      console.log vote.question
      events.add({
        time: vote.date + ' ' + vote.time
        title: vote.question
      })
    
    events.prepare()
    timeline.render()

    

