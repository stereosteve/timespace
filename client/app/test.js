var Spacetime = require('spacetime').Spacetime
window.Spacetime = Spacetime
window.st = new Spacetime()
console.log(st.format('LLLL'))

test("zeroOut", function() {
  ok(true);
})


test("refernce", function() {
  var st1 = new Spacetime([1984, 1, 22]);
  var st2 = new Spacetime();

  Spacetime.setRef("hello")
  equal(Spacetime.getRef(), "hello");
})

