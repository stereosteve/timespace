class CoffeeKupView extends Backbone.View
  renderTmpl: (ctx) =>
    @$(@el).html CoffeeKup.render(@tmpl, ctx)



class Span extends CoffeeKupView
  
  className: 'Span'

  initialize: (opts) ->
    @mmt = opts.mmt
    @units = opts.units

  tmpl: ->
    h2 @fmt

  fmt: =>
    @mmt.format 'LL' if @units == 'days'
    @mmt.format 'LLLL' if @units == 'hours'

  render: =>
    @renderTmpl(mmt: @mmt, fmt: @fmt())
    @$(@el).attr('data-mmt', @mmt)
    @$(@el).attr('data-date', @fmt())
    @
    

class Viewport extends Backbone.View

  className: 'Viewport'

  initialize: (opts) ->
    @j = @$(@el)
    @spans = []
    @center = moment([1984, 1, 22])
    @units = 'hours'
  
  render: =>
    @left = @center.clone()
    @right = @center.clone()
    @appendSpan() for i in [1..100]
    @

  resetWaypoints: =>
    $.waypoints().waypoint('destroy')
    @$('.Span').waypoint @spanScrolled, {offset: '50%'}

  spanScrolled: (ev, direction) =>
    mmt = moment($(ev.target).data('mmt'))
    if direction == 'up' and mmt.diff(@left, @units) < 10
      @prependSpan(true) for i in [1..10]
      $.scrollTo(ev.target, offset: -1 * $(window).height()/2)
      @resetWaypoints()

    if direction == 'down' and @right.diff(mmt, @units) < 10
      @appendSpan(true) for i in [1..10]
      $.scrollTo(ev.target, offset: -1 * $(window).height()/2)
      @resetWaypoints()

  prependSpan: (removeOne) =>
    @left.subtract(@units, 1)
    span = new Span(mmt: @left.clone(), units: @units)
    @spans.unshift(span)
    @j.prepend(span.render().el)

    if removeOne
      @right.subtract(@units, 1)
      @$(@spans.pop().el).remove()
  
  appendSpan: (removeOne) =>
    @right.add(@units, 1)
    span = new Span(mmt: @right.clone(), units: @units)
    @spans.push(span)
    @j.append(span.render().el)

    if removeOne
      @left.add(@units, 1)
      @$(@spans.shift().el).remove()

  gotoCenter: =>
    centerSpan = @spans[@spans.length/2]
    $.scrollTo(centerSpan.el, 100, {offset: -1 * $(window).height()/2})

$ ->
  window.viewport = new Viewport()
  $('body').html(viewport.render().el)
  viewport.gotoCenter()
  viewport.resetWaypoints()
