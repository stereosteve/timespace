
moment.fn.floor = (unit) ->
  mmt = @
  fl =
    minute: ->
      mmt.seconds(0)
    hour: ->
      fl['minute']()
      mmt.minutes(0)
    day: ->
      fl['hour']()
      mmt.hours(0)
    week: ->
      fl['day']()
      # TODO: set day of week to sunday / monday?
    month: ->
      fl['day']()
      mmt.date(1)
    year: ->
      fl['month']()
      mmt.month(0)


  unit = unit.replace(/s$/i, '')
  unit = 'day' if unit == 'date'
  fl[unit]()

