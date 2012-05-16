(function() {

  define(["dojo/main", "util/doh/main", "mizuhiki/abstraction/Dom", "dojo/_base/window", "dijit/dijit", "clazzy/Exception", "dijit/form/TextBox"], function(dojo, doh, dom, win, dijit, Exception) {
    return doh.register("mizuhiki.tests.abstraction.Dom", [
      {
        name: "body_null_body",
        setUp: function() {},
        runTest: function(t) {
          var body;
          body = win.body();
          return doh.assertEqual(document.body, body);
        }
      }, {
        name: "byId_id_element",
        setUp: function() {
          this.el = document.createElement('div');
          this.el.id = "dummy";
          return win.body().appendChild(this.el);
        },
        runTest: function(t) {
          var el;
          el = dom.byId(this.el.id);
          return doh.assertEqual(this.el, el);
        },
        tearDown: function() {
          return dom.destroy(this.el);
        }
      }, {
        name: "destroy_node_nodeIsDestroyed",
        setUp: function() {
          this.el = document.createElement('div');
          this.elementId = "dummy";
          this.el.id = this.elementId;
          return win.body().appendChild(this.el);
        },
        runTest: function(t) {
          var d, elementId;
          dom.destroy(this.el);
          elementId = this.elementId;
          d = new doh.Deferred();
          setTimeout(d.getTestCallback(function() {
            var el;
            el = dom.byId(elementId);
            return doh.assertEqual(null, el);
          }));
          return d;
        }
      }, {
        name: "create_validHtml_correctObject",
        setUp: function() {
          return this.html = "<div id=\"dummy\" class=\"foo\">bar</div>";
        },
        runTest: function(t) {
          var el;
          el = dom.create(this.html);
          doh.assertEqual("dummy", el.id);
          doh.assertEqual("foo", el.className);
          return doh.assertEqual("bar", el.innerHTML);
        }
      }, {
        name: "find_validClassQueryAndParent_correctNodeInArray",
        setUp: function() {
          return this.parent = dom.create("<div id=\"parent\"><span id=\"child1\" class=\"first\">foo</span><span id=\"child2\" class=\"second\">foo</span><span id=\"child3\" class=\"third\">foo</span></div>");
        },
        runTest: function(t) {
          var el;
          el = dom.find(".second", this.parent)[0];
          return doh.assertEqual("child2", el.id);
        }
      }, {
        name: "find_validIdQueryAndParentNotInDom_emptyArray",
        setUp: function() {
          return this.parent = dom.create("<div id=\"parent\"><span id=\"child1\" class=\"first\">foo</span><span id=\"child2\" class=\"second\">foo</span><span id=\"child3\" class=\"third\">foo</span></div>");
        },
        runTest: function(t) {
          var result;
          result = dom.find("#second", this.parent);
          return doh.assertTrue(result.length === 0);
        }
      }, {
        name: "find_validIdQueryAndParentInDom_correctNodeInArray",
        setUp: function() {
          this.parent = dom.create("<div id=\"parent\"><span id=\"child1\" class=\"first\">foo</span><span id=\"child2\" class=\"second\">foo</span><span id=\"child3\" class=\"third\">foo</span></div>");
          return win.body().appendChild(this.parent);
        },
        runTest: function(t) {
          var el;
          el = dom.find("#child2", this.parent)[0];
          return doh.assertEqual("child2", el.id);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "findAllWidgets",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\" data-dojo-type=\"dijit.form.TextBox\"></div><div id=\"div2\" data-dojo-type=\"dijit.form.TextBox\"></div>";
          win.body().appendChild(this.parent);
          return dom.parse(this.parent);
        },
        runTest: function(t) {
          this.widgets = dom.findAllWidgets(this.parent);
          return doh.assertTrue(this.widgets.length === 2);
        },
        tearDown: function() {
          var widget, _i, _len, _ref;
          _ref = this.widgets;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            widget = _ref[_i];
            widget.destroy();
          }
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_before",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, "div2", "before");
          return doh.assertEqual(this.el, dom.find("#div2").prev()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_before",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, "div2", "before");
          return doh.assertEqual(this.el, dom.find("#div2").prev()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_after",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, "div2", "after");
          return doh.assertEqual(this.el, dom.find("#div2").next()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_first",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, this.parent, "first");
          return doh.assertEqual(this.el, dom.find("#div1").prev()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_last",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, this.parent, "last");
          return doh.assertEqual(this.el, dom.find("#div3").next()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_only",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, this.parent, "only");
          doh.assertTrue(this.parent.childNodes.length === 1);
          return doh.assertEqual(this.el, this.parent.childNodes[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_defaultIsLast",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.place(this.el, this.parent);
          return doh.assertEqual(this.el, dom.find("#div3").next()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "place_node_replaceCallsReplace",
        setUp: function() {
          this.target = "dummy1";
          this.source = document.createElement('div');
          this.originalReplace = dom.replace;
          return dom.replace = function(source, target) {
            return {
              source: source,
              target: target
            };
          };
        },
        runTest: function(t) {
          var result;
          result = dom.place(this.target, this.source, "replace");
          doh.assertEqual(this.source, result.source);
          return doh.assertEqual(this.target, result.target);
        },
        tearDown: function() {
          return dom.replace = this.originalReplace;
        }
      }, {
        name: "replace",
        setUp: function() {
          this.parent = document.createElement('div');
          this.parent.id = "parent";
          this.parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>";
          win.body().appendChild(this.parent);
          this.el = document.createElement('div');
          return this.el.id = "dummy";
        },
        runTest: function(t) {
          dom.replace(dom.byId("div2"), this.el);
          doh.assertEqual(this.el, dom.find("#div1").next()[0]);
          return doh.assertEqual(this.el, dom.find("#div3").prev()[0]);
        },
        tearDown: function() {
          return dom.destroy(this.parent);
        }
      }, {
        name: "register_idAndObject_objectIsRegistered",
        setUp: function() {
          dom.unregister("dummy");
          return this.obj = {
            foo: "bar"
          };
        },
        runTest: function(t) {
          dom.register("dummy", this.obj);
          return doh.assertEqual(this.obj, window.U4.__registry.dummy);
        },
        tearDown: function() {
          return dom.unregister("dummy");
        }
      }, {
        name: "register_sameIdTwice_throws",
        setUp: function() {
          return this.obj = {
            foo: "bar"
          };
        },
        runTest: function(t) {
          dom.register("dummy", this.obj);
          return doh.assertError(Exception, dom, "register", ["dummy", this.obj]);
        },
        tearDown: function() {
          return dom.unregister("dummy");
        }
      }, {
        name: "unregister_id_objectIsUnregistered",
        setUp: function() {
          this.obj = {
            foo: "bar"
          };
          return dom.register("dummy", this.obj);
        },
        runTest: function(t) {
          dom.unregister("dummy");
          return doh.assertEqual(void 0, window.U4.__registry.dummy);
        }
      }, {
        name: "unregisterWidget_existingWidgetId_widgetIsRemoved",
        setUp: function() {
          return dijit.registry.add({
            id: "fakeWidget"
          });
        },
        runTest: function(t) {
          dom.unregisterWidget("fakeWidget");
          return doh.assertEqual(void 0, dijit.registry.byId("fakeWidget"));
        }
      }
    ]);
  });

}).call(this);
