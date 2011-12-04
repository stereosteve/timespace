var Spacetime = require('spacetime').Spacetime

test("zeroOut", function() {
  ok(true);
})

test("refernce", function() {
  var st1 = new Spacetime();
  var st2 = new Spacetime();

  Spacetime.setRef("hello")
  equal(Spacetime.getRef(), "hello");
})

