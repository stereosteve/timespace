Timeplane = require('../assets/javascripts/timeplane').Timeplane

describe "Timeplane", ->

  describe "currentScale", ->

    it "returns 69", ->

      tp = new Timeplane()

      tp.currentScale().should.equal(69)
