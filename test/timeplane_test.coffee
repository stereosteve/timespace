#Timeplane = require('../assets/javascripts/timeplane').Timeplane
jsdom = require('jsdom')

stitchPackage = stitch.createPackage({
  paths: [
    '../assets/javascripts',
    '../assets/vendor'
  ]
})


describe "Timeplane", ->

  describe "currentScale", ->

    it "returns 69", ->
      env = jsdom.env
        html: "<html><body></body></html>"
        src: []
        (err, window) ->


      tp = new Timeplane()

      tp.currentScale().should.equal(69)
