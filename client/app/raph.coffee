models = require('models')
views = require('views')


secondsPerPixel = .01 # one minute in every pixel - screen should be like 700 minutes


pixelDiff = (start, mmt) ->
  #[mmt, start] = [start, mmt] if start > mmt
  diff = mmt.diff(start)
  diff / secondsPerPixel


draw = (events) ->
  start = events.startDate
  console.log pixelDiff(start, start)
  console.log pixelDiff(start, events.endDate)
  console.log events.endDate.diff(start)

  events.each (event) ->
    view = new views.EventView(model: event)
    $('body').append(view.render().el)
  
  $(".EventView").each (i, child) =>
    child = $(child)
    mmt = moment(child.data('mmt'))
    console.log mmt
    yPos = pixelDiff(events.startDate, mmt)
    child.css 'top', yPos

$ ->
  window.ows = new models.EventCollection()
  $.getJSON '/data/ows.json', (data) ->
    ows.reset(data.results)
    draw(ows)

