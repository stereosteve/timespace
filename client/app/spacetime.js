(function() {

  var Moment = moment.fn;

  var Spacetime = Backbone.Model.extend(
  // Prototype properties (each instance)
  {

    initialize: function(attributes, options) {
      console.log(attributes)
      console.log(options)
      this._d = new Date()
    },

    zeroOut: function(unit) {
    }

  }, 
  // Constructor function properties (Spacetime class)
  {

    getRef: function() {
      return this._ref;
    },

    setRef: function(newRef) {
      this._ref = newRef;
    }

  })

  _.extend(Spacetime.prototype, Moment)

  exports.Spacetime = Spacetime

})()
