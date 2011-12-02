moment = require('moment')
Backbone = require('backbone')



convertDiff = (seconds, output) ->
  now = moment()
  moment(now+seconds).diff(now, output)

getDiff = (unit, value) ->
  now = moment()
  next = now.clone().add(unit, value)
  next.diff(now)

THOUSAND_YEARS = getDiff('years', 1000)

class Controls extends Backbone.View
  className: 'RaphControls'

  initialize: (opts) ->
    @axis = opts.axis
    @render()

  tmpl: ->
    div '.slider', ''
    ul ->
      li '.century', 'Century'
      li '.decade', 'Decade'
      li '.years', 'Year'
      li '.months', 'Month'
      li '.weeks', 'Week'
      li '.days', 'Day'
  
  events:
    "click li": "setScale"
  
  setScale: (ev) ->
    unit = $(ev.target).attr('class')
    if unit is 'century'
      diff = getDiff('years', 100)
    else if unit is 'decade'
      diff = getDiff('years', 10)
    else
      diff = getDiff(unit, 1)
      
    @axis.setScreenDiff(diff)
    console.log @axis.spp
    @$('.slider').slider('value', @axis.spp)

  render: =>
    @$(@el).html CoffeeKup.render(@tmpl)
    @$('.slider').slider
      slide: (e, ui) =>
        console.log ui.value
        #@axis.spp = v
        #@axis.redraw()
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

  setScreenDiff: (diff) =>
    @spp = Math.floor(diff / $(window).height())
    @redraw()



  render: =>
    $el = @$(@el)
    @spp =  @diff / $el.height()
    @paper = Raphael(@el, $el.width(), $el.height())
    @redraw()
    @
  
  redraw: =>
    $el = @$(@el)
    @paper.clear()

    # Draw Years
    @drawLabels('years', 'YYYY', 80)

    # Draw Months
    if @screenDiff('months') < 50
      @drawLabels('months', 'MMMM', 50)
    
    # Draw Days
    if @screenDiff('days') < 80
      @drawLabels('days', 'dddd', 20)




  drawLabels: (unit, format, line) =>
    #debugger
    mmt = @start.clone()
    point = 0
    while mmt < @end and point < $(window).height()
      point = @timeToPosition(mmt)
      path = @paper.path("M0,#{point} H#{line}")
      path.attr('stroke-width', 2)
      text = @paper.text(1, point+5, mmt.format(format))
      text.attr('text-anchor', 'start')    
      mmt.add(unit, 1)


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

  

