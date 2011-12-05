
moment.fn.zeroOut = (unit) ->
  units = ['seconds', 'minutes', 'hours', 'days', 'weeks', 'months', 'years']
  i = units.indexOf(unit)
  if i > -1
    @seconds(0)
  if i > 0
    @minutes(0)
  if i > 1
    @hours(0)
  if i > 3
    @date(1)
  if i > 5
    @month(0)
  @
