diffs = require '../assets/javascripts/diffs'

describe 'Array', ->
  it 'works', ->
    [1,2,3].indexOf(4).should.equal(-1)

describe 'date difference', ->
  it 'is 1 day', ->
    diffs.dates().should.equal(86400000)
