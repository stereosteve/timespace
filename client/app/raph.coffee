moment = require('moment')
Backbone = require('backbone')



$ ->
  paper = Raphael(0, 0, "100%", "100%")
  rect = paper.rect(0, 0, "100%", "100%")
  rect.attr('fill', '#300')

  $('body').append(paper)

  $(window).scroll (ev) ->
    console.log ev
  

