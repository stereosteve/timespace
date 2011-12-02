moment = require('moment')
Backbone = require('backbone')

MAX_SPP = 486124775

convertDiff = (seconds, output) ->
  now = moment()
  moment(now+seconds).diff(now, output)

getDiff = (unit, value) ->
  now = moment()
  next = now.clone().add(unit, value)
  next.diff(now)



class Controls extends Backbone.View
  className: 'RaphControls'

  initialize: (opts) ->
    @axis = opts.axis
    @render()

  tmpl: ->
    div '.slider', ''
  
  render: =>
    @$(@el).html CoffeeKup.render(@tmpl)
    @$('.slider').slider
      max: MAX_SPP
      step: MAX_SPP / 1000
      slide: (e, ui) =>
        #console.log ui.value
        @axis.spp = MAX_SPP - ui.value
        @axis.redraw()
    @




class Axis extends Backbone.View
  className: 'Axis'

  initialize: (opts) ->
    @spacing = 20
    @start = moment([1990])
    @end = moment([2002])
    @diff = @end.diff(@start)
    # Seconds Per Pixel
    @spp = 1

  
  # takes a Seconds diff and returns a span of pixels
  diffToPixels: (diff) =>
    ~~ (diff / @spp) 

  # takes a span of pixels and converts to Seconds diff
  pixelsToDiff: (pixels) =>
    Math.floor(pixels * @spp)


  # takes a absolute time and returns the position
  timeToPosition: (time) =>
    time = moment(time)
    @diffToPixels(time.diff(@start))
  
  # takes a y coordinate and returns the time
  positionToTime: (y) =>
    diff = @pixelsToDiff(y)
    moment(@start + diff)
  
  # returns the diff for the screen hieght - ie how many seconds are showing
  # pass 'years, months, weeks, days' if you dont want seconds
  screenDiff: (unit) =>
    d = @pixelsToDiff($(window).height())
    d = convertDiff(d, unit) if unit?
    d





  render: =>
    $el = @$(@el)
    @spp =  @diff / $el.height()
    console.log @spp
    @paper = Raphael(@el, $el.width(), $el.height())
    @redraw()
    @
  
  redraw: =>
    $el = @$(@el)
    @paper.clear()

    console.log @screenDiff()

    mmt = @start.clone()
    while mmt < @end
      mmt.add('years', 1)
      @drawYear(mmt)

    if @screenDiff('months') < 50
      mmt = @start.clone()
      while mmt < @end
        mmt.add('months', 1)
        @drawMonth(mmt)


  drawYear: (mmt) =>
    p = @timeToPosition(mmt)
    path = @paper.path("M0,#{p} H40")
    path.attr('stroke-width', 2)
    text = @paper.text(1, p+5, mmt.format('YYYY'))
    text.attr('text-anchor', 'start')
  
  drawMonth: (mmt) =>
    p = @timeToPosition(mmt)
    path = @paper.path("M0,#{p} H20")
    path.attr('stroke-width', 1)



#### Main

$ ->
  axis = new Axis()
  controls = new Controls(axis: axis)
  $('body').append(axis.el)
  $('body').append(controls.el)
  axis.render()
  controls.render()

  rescale = ->
    axis.spacing += 1
    axis.redraw()
  #setInterval rescale, 10

  

