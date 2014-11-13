(function() {

  define(["dojo/main", "util/doh/main", "mizuhiki/abstraction/Lang", "clazzy/Exception"], function(dojo, doh, lang, Exception) {
    return doh.register("mizuhiki.tests.abstraction.Lang", [
      {
        name: "clone_objectWithObjectWithArrayInsideArray_areEqual",
        setUp: function() {
          return this.testObject = {
            a: {
              b: [[true, true], [false, false]]
            }
          };
        },
        runTest: function(t) {
          var clone;
          clone = lang.clone(this.testObject);
          return doh.assertEqual(this.testObject, clone);
        }
      }, {
        name: "eventOn_eventToFunction_functionIsCalledOnEvent",
        setUp: function() {
          return this.node = document.createElement("div");
        },
        runTest: function(t) {
          var wasCalled;
          wasCalled = false;
          this.func1 = function() {
            return wasCalled = true;
          };
          lang.event.on(this.node, "click", this, "func1");
          lang.event.emit(this.node, "click");
          return doh.assertTrue(wasCalled);
        }
      }, {
        name: "eventRemove_eventToFunction_functionIsNotCalledOnEvent",
        setUp: function() {
          return this.node = document.createElement("div");
        },
        runTest: function(t) {
          var handle, wasCalled;
          wasCalled = false;
          this.func1 = function() {
            return wasCalled = true;
          };
          handle = lang.event.on(this.node, "click", this, "func1");
          lang.event.remove(handle);
          lang.event.emit(this.node, "click");
          return doh.assertFalse(wasCalled);
        }
      }, {
        name: "aspectBefore_functionToFunction_secondFunctionIsCalledWithSameArguments",
        setUp: function() {},
        runTest: function(t) {
          var a1, a2, wasCalled;
          wasCalled = "";
          a1 = true;
          a2 = false;
          this.func1 = function(arg1, arg2) {
            return wasCalled = wasCalled + "func1";
          };
          this.func2 = function(arg1, arg2) {
            wasCalled = wasCalled + (arg1 === a1 && arg2 === a2 ? "func2" : "");
            return [arg1, arg2];
          };
          lang.aspect.before(this, "func1", this, this.func2);
          this.func1(a1, a2);
          return doh.assertEqual("func2func1", wasCalled);
        }
      }, {
        name: "aspectAround_functionToFunction_secondFunctionIsCalledWithSameArguments",
        setUp: function() {},
        runTest: function(t) {
          var a1, a2, wasCalled;
          wasCalled = "";
          a1 = true;
          a2 = false;
          this.func1 = function(arg1, arg2) {
            return wasCalled = wasCalled + "func1";
          };
          this.func2 = function(originalFunc) {
            return function(arg1, arg2) {
              wasCalled = wasCalled + (arg1 === a1 && arg2 === a2 ? "func2" : "");
              originalFunc(arg1, arg2);
              return wasCalled = wasCalled + (arg1 === a1 && arg2 === a2 ? "func2" : "");
            };
          };
          lang.aspect.around(this, "func1", this, this.func2);
          this.func1(a1, a2);
          return doh.assertEqual("func2func1func2", wasCalled);
        }
      }, {
        name: "aspectAfter_functionToFunction_secondFunctionIsCalledWithSameArguments",
        setUp: function() {},
        runTest: function(t) {
          var a1, a2, wasCalled;
          wasCalled = "";
          a1 = true;
          a2 = false;
          this.func1 = function(arg1, arg2) {
            return wasCalled = wasCalled + "func1";
          };
          this.func2 = function(arg1, arg2) {
            return wasCalled = wasCalled + (arg1 === a1 && arg2 === a2 ? "func2" : "");
          };
          lang.aspect.after(this, "func1", this, this.func2);
          this.func1(a1, a2);
          return doh.assertEqual("func1func2", wasCalled);
        }
      }, {
        name: "aspectRemove_handle_secondFunctionIsNotCalled",
        setUp: function() {
          this.wasCalled = false;
          this.a1 = true;
          this.a2 = false;
          this.func1 = function(arg1, arg2) {
            return null;
          };
          this.func2 = function(arg1, arg2) {
            console.log("func2");
            return this.wasCalled = arg1 === this.a1 && arg2 === this.a2;
          };
          return this.handle = lang.aspect.after(this, "func1", this, this.func2);
        },
        runTest: function(t) {
          lang.aspect.remove(this.handle);
          this.func1(this.a1, this.a2);
          return doh.assertFalse(this.wasCalled);
        }
      }, {
        name: "hitch_contextAndFunction_hitchedFunctionRunsSetContext",
        setUp: function() {
          this.context = {};
          return this.hitch = lang.hitch(this.context, function() {
            return this;
          });
        },
        runTest: function(t) {
          var context;
          context = this.hitch();
          return doh.assertEqual(this.context, context);
        }
      }, {
        name: "hitch_nullContextAndFunction_hitchedFunctionRunsThisContext",
        setUp: function() {
          this.context = null;
          return this.hitch = lang.hitch(this.context, function() {
            return this;
          });
        },
        runTest: function(t) {
          var context;
          context = this.hitch();
          return doh.assertEqual(this, context);
        }
      }, {
        name: "trim_undefined_ThrowsTypeError",
        setUp: function() {
          return this.string = void 0;
        },
        runTest: function(t) {
          return doh.assertError(TypeError, lang, "trim", [this.string]);
        }
      }, {
        name: "trim_null_ThrowsTypeError",
        setUp: function() {
          return this.string = null;
        },
        runTest: function(t) {
          return doh.assertError(TypeError, lang, "trim", [this.string]);
        }
      }, {
        name: "trim_stringWithSpacesAroundAndInside_stringWithoutSpacesAround",
        setUp: function() {
          return this.stringWithSpaces = " text here ";
        },
        runTest: function(t) {
          var trimmedString;
          trimmedString = lang.trim(this.stringWithSpaces);
          return doh.assertEqual("text here", trimmedString);
        }
      }
    ]);
  });

}).call(this);
