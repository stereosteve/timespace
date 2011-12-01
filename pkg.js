var stitch = require('stitch')

var stitchPackage = stitch.createPackage({
  paths: [
    __dirname + '/client/app',
    __dirname + '/client/modules'
  ],
  dependencies: [
    __dirname + '/public/vendor/js/jquery.js',
    __dirname + '/public/vendor/js/jqueryui.js',
    __dirname + '/public/vendor/js/coffeekup.js'
  ]
})


exports.stitchPackage = stitchPackage

if (require.main === module) {

  stitchPackage.compile(function(err, source) {
    console.log(source)
  })

}
