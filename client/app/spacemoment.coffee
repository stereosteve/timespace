_.extend(moment.fn, Backbone.Events)

moment.fn.scale = (scale) ->
  if scale
    @__proto__.mspp = scale
    @trigger('scaleChanged', scale)
  else
    @__proto__.mspp || 69

moment.fn.zeroOut = (unit) ->
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