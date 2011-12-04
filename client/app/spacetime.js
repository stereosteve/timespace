exports.Spacetime = Backbone.Model.extend({

  zeroOut: function(unit) {
  }

}, {

  getRef: function() {
    return this._ref;
  },

  setRef: function(newRef) {
    this._ref = newRef;
  }

})
