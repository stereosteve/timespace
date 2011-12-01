var stitch = require('stitch')

var stitchPackage = stitch.createPackage({
  paths: [
    __dirname + '/client/app',
    __dirname + '/client/vendor/modules'
  ],
  dependencies: [
    __dirname + '/client/vendor/dependencies/jquery.js',
    __dirname + '/client/vendor/dependencies/coffeekup.js'
  ]
})


exports.stitchPackage = stitchPackage

if (require.main === module) {

  stitchPackage.compile(function(err, source) {
    console.log(source)
  })

}
