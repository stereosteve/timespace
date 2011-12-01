Backbone = require('backbone')

class TimeGrid extends Backbone.View

  tmpl: ->
    h1 'this is how we do it'

  render: =>
    @el = CoffeeKup.render(@tmpl, {})
    @


$ ->
  tg = new TimeGrid()
  tg.render()

  $('body').html tg.el
