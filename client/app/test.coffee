require('spacemoment')

test "zeroOut", ->
  m = moment().zeroOut('minutes')
  equal(m.seconds(), 0)
  equal(m.minutes(), 0)

test "scale", ->
  m1 = moment()
  m2 = moment()

  m1.bind 'scaleChanged', (newScale) ->
    console.log "Scale changed to #{newScale}"
  
  equal(m1.scale(), 69)
  equal(m2.scale(), 69)

  m1.scale(70)
  equal(m1.scale(), 70)
  equal(m2.scale(), 70)