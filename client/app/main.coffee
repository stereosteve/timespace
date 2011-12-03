################################################################
# Models

#### Event
class Event extends Backbone.Model

  initialize: ->
    @mmt = moment(@get('time'))
    @bind("all", @changed)
    @changed()
  
  changed: =>
    @mmt = moment(@get('time')) if @get('time')
    @mmt = moment(@get('created_at')) if @get('created_at')



#### EventCollection
class EventCollection extends Backbone.Collection
  model: Event

  initialize: ->
    #@bind('add', @changed)
    @bind('add', @changed)
    @bind('reset', @changed)

  changed: =>
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
    div '.title', @event.get('text')
    div @event.mmt.format("LLLL")

  render: =>
    $el = @$(@el)
    $el.html CoffeeKup.render(@tmpl, {event: @event})
    $el.attr('data-mmt', @event.mmt)
    @




#### AxisView
class AxisView extends Backbone.View
  className: 'AxisView'

  initialize: (opts) ->
    @e = @$(@el)
    @timeline = opts.timeline
  
  render: =>
    startDate = @timeline.events.startDate
    endDate = @timeline.events.endDate
    # hours
    h = startDate.clone().seconds(0).minutes(0).add('hours', 1)
    while h < endDate
      $('body').append("<div class='Temporal HourMarker' data-mmt='#{h}'>#{h.format('HH:mm')}</div>")
      h.add('hours', 1)
    
    # half hours
    h = startDate.clone().seconds(0).minutes(30).add('hours', 1)
    while h < endDate
      $('body').append("<div class='Temporal HalfHourMarker' data-mmt='#{h}'>#{h.format('HH:mm')}</div>")
      h.add('hours', 1)
    


#### TimelineView
class TimelineView extends Backbone.View
  className: 'TimelineView'

  initialize: (opts) ->
    @e = @$(@el)
    @secondsPerPixel = opts.secondsPerPixel || 10000
    @events = opts.events
    @axis = new AxisView(timeline: @)
    @events.bind('all', @eventsChanged)

  eventsChanged: =>
    @e.height( @events.diff / @secondsPerPixel )
    @e.attr 'data-mmt', @events.startDate

    @events.each (event) =>
      view = new EventView(model: event)
      @e.append(view.render().el)
    
    @axis.render()
    @render()
  
  render: =>
    $(".Temporal").each (i, child) =>
      child = $(child)
      mmt = moment(child.data('mmt'))
      yPos = mmt.diff(@events.startDate) / @secondsPerPixel
      child.css 'top', yPos

  

  

################################################################
# Main

$ ->
  hackday = new EventCollection()

  timeline = new TimelineView(events: hackday)
  $('body').append timeline.el

  $.getJSON '/data/twitter-hackday.json', (data) ->
    hackday.reset(data.results)
