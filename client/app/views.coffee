class CoffeeKupView extends Backbone.View
  renderTmpl: (ctx) =>
    @$(@el).html CoffeeKup.render(@tmpl, ctx)

class Tspan extends CoffeeKupView
  
  className: 'Tspan'

  initialize: (opts) ->
    @mmt = opts.mmt

  tmpl: ->
    h2 @mmt.format('LL')

  render: =>
    @renderTmpl(mmt: @mmt)
    #@$(@el).attr('data-mmt', @mmt)
    @$(@el).attr('data-date', @mmt.format('LL'))
    @
    


class Viewport extends Backbone.View

  className: 'Viewport'

  initialize: (opts) ->
    @j = @$(@el)

    # center date
    @centerDate = moment([1984, 1, 22])
    # hold an array of spans
    @tspans = []
    window.tspans = @tspans
    
    @min = -100
    @max = 100
    @left = moment([1984, 1, 7])
    @right = moment([1984, 3, 7])

    # rename lowerBound to left and right
    # use lowerBound and upperBound for min and max
    #
    #$(window).scroll(@windowScrolled)
  
  render: =>
    #@$(span.el).waypoint(@scrolled)
    
    l = @left.clone()
    r = @right.clone()
    while l < r
      span = new Tspan(mmt: l.clone())
      @tspans.push(span)
      @j.append(span.render().el)
      l.add('days',1)
    @resetWaypoints()
    $.scrollTo(@tspans[@tspans.length/2].el)
    @

  resetWaypoints: =>
    $.waypoints().waypoint('destroy')
    $(@tspans[1].el).waypoint @nearTop
    $(@tspans[@tspans.length - 10].el).waypoint @nearBottom
    console.log $.waypoints()

  nearTop: (ev, direction) =>
    if direction == 'up'
      console.log 'near top'
      @prependTspan(true) for i in [1..10]
      @resetWaypoints()
      $.scrollTo(ev.target)

  nearBottom: (ev, direction) =>
    if direction == 'down'
      console.log 'near bottom'
      @appendTspan(true) for i in [1..10]
      @resetWaypoints()
      $.scrollTo(ev.target)




  prependTspan: (removeOne) =>
    @left.subtract('days', 1)
    console.log "prepending "+@left.format("LL")
    span = new Tspan(mmt: @left.clone())
    @tspans.unshift(span)
    @j.prepend(span.render().el)
    #@$(span.el).waypoint(@scrolled)
    
    if removeOne
      last = @tspans.pop()
      @$(last.el).remove()
  
  appendTspan: (removeOne) =>
    @right.add('days', 1)
    console.log "appending "+@right.format("LL")
    span = new Tspan(mmt: @right.clone())
    @tspans.push(span)
    @j.append(span.render().el)
    if removeOne
      first = @tspans.shift()
      @$(first.el).remove()


$ ->
  window.viewport = new Viewport()
  $('body').html(viewport.render().el)
