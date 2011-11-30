var stitch = require('stitch')

var stitchPackage = stitch.createPackage({
  paths: [
    __dirname + '/assets/javascripts',
    __dirname + '/assets/vendor'
  ]
})


exports.stitchPackage = stitchPackage

if (require.main === module) {

  stitchPackage.compile(function(err, source) {
    console.log(source)
  })

}
