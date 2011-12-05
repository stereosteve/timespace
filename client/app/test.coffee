require('moment_ext')

# Zero Out
#   TODO: zeroOut is inconsistent when you get above hours
#
#   floor would be a better name:
#     floor('minute') - chops seconds
#     floor('hour') - chops seconds, minutes
#     floor('day') - chops hours minutes seconds
#     floor('month') - sets date to 1
#     floor('year') - sets month to 0
#
#   Support single and pluaral (day / days)

test "minute", ->
  now = moment()
  m = now.clone().floor('minutes')
  equal(m.seconds(), 0)
  equal(m.minutes(), now.minutes())

test "hour", ->
  now = moment()
  m = now.clone().floor('hour')
  equal(m.seconds(), 0)
  equal(m.minutes(), 0)
  equal(m.hours(), now.hours())
  equal(m.date(), now.date())


test "day", ->
  now = moment()
  m = now.clone().floor('day')

  # zeros out hour, minute, second
  equal(m.seconds(), 0)
  equal(m.minutes(), 0)
  equal(m.hours(), 0)

  # leaves date, month, year
  equal(m.date(), now.date())
  equal(m.month(), now.month())
  equal(m.year(), now.year())

test "month", ->
  now = moment()
  m = now.clone().floor('months')

  equal(m.seconds(), 0)
  equal(m.minutes(), 0)
  equal(m.hours(), 0)
  equal(m.date(), 1)

  equal(m.month(), now.month())

test "year", ->
  now = moment()
  m = now.clone().floor('years')

  equal(m.seconds(), 0)
  equal(m.minutes(), 0)
  equal(m.hours(), 0)
  equal(m.date(), 1)
  equal(m.month(), 0)

  equal(m.year(), now.year())
