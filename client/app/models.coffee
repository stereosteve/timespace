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

  mean: ->
    @sorted().at(Math.floor(@length/2))

  between: (start, end) ->
    new EventCollection @filter (event) ->
      event.mmt.valueOf() == start.valueOf() or (event.mmt > start and event.mmt < end)

  groupByDate: ->
    groups = {}
    @each (event) ->
      key = event.mmt.clone().floor('hours')
      groups[key.valueOf()] ||= []
      groups[key.valueOf()].push(event)
    groups
      
exports.Event = Event
exports.EventCollection = EventCollection
