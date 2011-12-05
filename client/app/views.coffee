class CoffeeKupView extends Backbone.View
  renderTmpl: (ctx) =>
    @$(@el).html CoffeeKup.render(@tmpl, ctx)
    @


class Tile extends CoffeeKupView
  className: 'Tile'
  render: =>
    @j = @$(@el)
    @j.text @model.get('title')
    @j.attr('data-mmt', @model.mmt)
    @j.attr('data-date', @model.mmt.format('LLLL'))
    @


class Span extends CoffeeKupView
  
  className: 'Span'

  initialize: (opts) ->
    @mmt = opts.mmt
    @units = opts.units

  tmpl: ->
    h2 @fmt
    div '.tiles', ''

  fmt: =>
    return @mmt.format 'YYYY' if @units == 'years'
    return @mmt.format 'MMM YY' if @units == 'months'
    return @mmt.format 'LL' if @units == 'weeks'
    return @mmt.format 'LL' if @units == 'days'
    return @mmt.format 'ddd h a' if @units == 'hours'
    return @mmt.format 'h:mm a' if @units == 'minutes'

  render: =>
    @renderTmpl(mmt: @mmt, fmt: @fmt())
    @j = @$(@el)
    for event in @collection.sorted().models
      @$('.tiles').append(new Tile(model: event).render().el)
    @j.attr('data-mmt', @mmt)
    @j.attr('data-date', @fmt())
    @
    
class Controls extends CoffeeKupView
  className: 'Controls'

  initialize: (opts) ->
    @viewport = opts.viewport

  tmpl: ->
    div '.CenterDate', 'center date'
    select '.grouping', ->
      option value: 'minutes', 'Minute'
      option value: 'hours', 'Hour'
      option value: 'days', 'Day'
      option value: 'weeks', 'Week'
      option value: 'months', 'Month'
      option value: 'years', 'Year'

    button '.btn.zoomout', '-'
    button '.btn.zoomin', '+'
  
  events:
    'click .zoomout': 'zoomout'
    'click .zoomin': 'zoomin'
    'change .grouping': 'regroup'

  regroup: =>
    grouping = @$('.grouping').val()
    @viewport.units = grouping
    @viewport.render()

  zoomout: =>
  
  zoomin: =>

  render: => @renderTmpl()

class Viewport extends Backbone.View

  className: 'Viewport'

  initialize: (opts) ->
    @j = @$(@el)
    @spans = []
    @center = moment([1984, 1, 22])
    @units = 'days'
    @controls = new Controls(viewport: @)
    $('body').html @controls.render().el
    $('body').append(@el)
    $('.Controls .grouping').val(@units)
  
  render: =>
    @spans = []
    @j.empty()
    @center = @collection.mean().mmt.clone().zeroOut(@units)
    @left = @center.clone()
    @right = @center.clone().subtract(@units,1)
    @prependSpan() for i in [1..50]
    @appendSpan() for i in [1..50]
    @gotoCenter()
    @resetWaypoints()
    console.log @units
    @

  resetWaypoints: (el) =>
    $.waypoints().waypoint('destroy')
    @$('.Span').waypoint @spanScrolled, {offset: '50%'}

  spanScrolled: (ev, direction) =>
    mmt = moment($(ev.target).data('mmt'))
    if direction == 'up'
      $('.CenterDate').text(mmt.subtract(@units, 1).format('LL'))
      if mmt.diff(@left, @units) < 10
        shifted = true
        @prependSpan(true) for i in [1..10]
    if direction == 'down'
      $('.CenterDate').text(mmt.format('LL'))
      if @right.diff(mmt, @units) < 10
        shifted = true
        @appendSpan(true) for i in [1..10]
    if shifted
      $.scrollTo(ev.target, offset: -1 * $(window).height()/2)
      @resetWaypoints()

  prependSpan: (removeOne) =>
    @left.subtract(@units, 1)
    span = @makeSpan(@left)
    @spans.unshift(span)
    @j.prepend(span.render().el)

    if removeOne
      @right.subtract(@units, 1)
      @$(@spans.pop().el).remove()
  
  appendSpan: (removeOne) =>
    @right.add(@units, 1)
    span = @makeSpan(@right)
    @spans.push(span)
    @j.append(span.render().el)

    if removeOne
      @left.add(@units, 1)
      @$(@spans.shift().el).remove()

  makeSpan: (mmt) =>
    mmt = mmt.clone()
    events = @collection.between(mmt, mmt.clone().add(@units, 1))
    span = new Span(mmt: mmt, units: @units, collection: events)

  gotoCenter: =>
    centerSpan = @spans[@spans.length/2]
    $.scrollTo(centerSpan.el, 100, {offset: -1 * $(window).height()/2})

exports.Viewport = Viewport

if false
  $ ->
    window.viewport = new Viewport()
    viewport.render()
