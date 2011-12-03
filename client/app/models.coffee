#### Event
class Event extends Backbone.Model

  initialize: ->
    @mmt = moment()
    @bind("all", @changed)
  
  changed: =>
    @mmt = moment(@get('time')) if @hasChanged('time')
    @mmt = moment(@get('created_at')) if @hasChanged('created_at')
    console.log @mmt.format('LLLL')



#### EventCollection
class EventCollection extends Backbone.Collection
  model: Event

  initialize: ->
    #@bind('add', @changed)
    @bind('all', @changed)

  changed: =>
    @startDate = @sorted().first().mmt
    @endDate = @sorted().last().mmt
    @diff = @endDate.diff(@startDate)

  sorted: ->
    new EventCollection(@sortBy (event) -> event.mmt)

exports.Event = Event
exports.EventCollection = EventCollection