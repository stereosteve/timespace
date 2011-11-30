moment = require('moment')

exports.dates = ->
  yesterday = moment([2011, 11, 29])
  today = moment([2011, 11, 30])
  today.diff(yesterday)

