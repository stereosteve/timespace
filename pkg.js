var stitch = require('stitch')

var stitchPackage = stitch.createPackage({
  paths: [
    __dirname + '/client/app',
    __dirname + '/client/vendor'
  ],
  dependencies: [
    __dirname + '/client/deps/jquery.js',
    __dirname + '/client/deps/coffeekup.js'
  ]
})


exports.stitchPackage = stitchPackage

if (require.main === module) {

  stitchPackage.compile(function(err, source) {
    console.log(source)
  })

}
