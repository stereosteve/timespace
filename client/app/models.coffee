#### Event
class Event extends Backbone.Model

  initialize: ->
    @time = moment(@get('time'))


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

exports.Event = Event
exports.EventCollection = EventCollection