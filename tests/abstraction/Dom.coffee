define [
    "dojo/main" 
    "util/doh/main" 
    "mizuhiki/abstraction/Dom" 
    "dojo/_base/window"
    "dijit/dijit" 
    "clazzy/Exception" 
    "dijit/form/TextBox"
], (dojo, doh, dom, win, dijit, Exception) ->

    doh.register "mizuhiki.tests.abstraction.Dom", [

        name: "body_null_body"
        setUp: () ->
            #Arrange
        runTest: (t) -> 
            #Act
            body = win.body()
            #Assert
            doh.assertEqual document.body, body
    ,
        name: "byId_id_element"
        setUp: () ->
            #Arrange
            @el = document.createElement 'div'
            @el.id = "dummy"
            win.body().appendChild @el
        runTest: (t) -> 
            #Act
            el = dom.byId @el.id
            #Assert
            doh.assertEqual @el, el
        tearDown: () ->
            dom.destroy @el
    ,
        name: "destroy_node_nodeIsDestroyed"
        setUp: () ->
            #Arrange
            @el = document.createElement 'div'
            @elementId = "dummy"
            @el.id = @elementId
            win.body().appendChild @el
        runTest: (t) -> 
            #Act
            #Assert
            dom.destroy @el
            elementId = @elementId
            d = new doh.Deferred()
            setTimeout d.getTestCallback () ->
                el = dom.byId elementId
                doh.assertEqual null, el
            d
    ,
        name: "create_validHtml_correctObject"
        setUp: () ->
            #Arrange
            @html = "<div id=\"dummy\" class=\"foo\">bar</div>"
        runTest: (t) -> 
            #Act
            el = dom.create @html
            #Assert
            doh.assertEqual "dummy", el.id
            doh.assertEqual "foo", el.className
            doh.assertEqual "bar", el.innerHTML
    ,
        name: "find_validClassQueryAndParent_correctNodeInArray"
        setUp: () ->
            #Arrange
            @parent = dom.create "<div id=\"parent\"><span id=\"child1\" class=\"first\">foo</span><span id=\"child2\" class=\"second\">foo</span><span id=\"child3\" class=\"third\">foo</span></div>"
        runTest: (t) -> 
            #Act
            el = dom.find(".second", @parent)[0]
            #Assert
            doh.assertEqual "child2", el.id
    ,
        name: "find_validIdQueryAndParentNotInDom_emptyArray"
        setUp: () ->
            #Arrange
            @parent = dom.create "<div id=\"parent\"><span id=\"child1\" class=\"first\">foo</span><span id=\"child2\" class=\"second\">foo</span><span id=\"child3\" class=\"third\">foo</span></div>"
        runTest: (t) -> 
            #Act
            result = dom.find("#second", @parent)
            #Assert
            doh.assertTrue result.length is 0
    ,
        name: "find_validIdQueryAndParentInDom_correctNodeInArray"
        setUp: () ->
            #Arrange
            @parent = dom.create "<div id=\"parent\"><span id=\"child1\" class=\"first\">foo</span><span id=\"child2\" class=\"second\">foo</span><span id=\"child3\" class=\"third\">foo</span></div>"
            win.body().appendChild @parent
        runTest: (t) -> 
            #Act
            el = dom.find("#child2", @parent)[0]
            #Assert
            doh.assertEqual "child2", el.id
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "findAllWidgets"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\" data-dojo-type=\"dijit.form.TextBox\"></div><div id=\"div2\" data-dojo-type=\"dijit.form.TextBox\"></div>"
            win.body().appendChild @parent
            dom.parse @parent
        runTest: (t) -> 
            #Act
            @widgets = dom.findAllWidgets @parent
            #Assert
            doh.assertTrue @widgets.length is 2
        tearDown: () ->
            for widget in @widgets
                widget.destroy()
            dom.destroy @parent
    ,
        name: "place_node_before"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, "div2", "before"
            #Assert
            doh.assertEqual @el, dom.find("#div2").prev()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_before"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, "div2", "before"
            #Assert
            doh.assertEqual @el, dom.find("#div2").prev()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_after"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, "div2", "after"
            #Assert
            doh.assertEqual @el, dom.find("#div2").next()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_first"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, @parent, "first"
            #Assert
            doh.assertEqual @el, dom.find("#div1").prev()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_last"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, @parent, "last"
            #Assert
            doh.assertEqual @el, dom.find("#div3").next()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_only"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, @parent, "only"
            #Assert
            doh.assertTrue @parent.childNodes.length is 1
            doh.assertEqual @el, @parent.childNodes[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_defaultIsLast"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.place @el, @parent
            #Assert
            doh.assertEqual @el, dom.find("#div3").next()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "place_node_replaceCallsReplace"
        setUp: () ->
            #Arrange
            @target = "dummy1"
            @source = document.createElement 'div'
            @originalReplace = dom.replace
            dom.replace = (source, target) -> {source:source, target:target}
        runTest: (t) -> 
            #Act
            result = dom.place @target, @source, "replace"
            #Assert
            doh.assertEqual @source, result.source
            doh.assertEqual @target, result.target
        tearDown: () ->
            dom.replace = @originalReplace
    ,
        name: "replace"
        setUp: () ->
            #Arrange
            @parent = document.createElement 'div'
            @parent.id = "parent"
            @parent.innerHTML = "<div id=\"div1\"></div><div id=\"div2\"></div><div id=\"div3\"></div>"
            win.body().appendChild @parent
            @el = document.createElement 'div'
            @el.id = "dummy"
        runTest: (t) -> 
            #Act
            dom.replace dom.byId("div2"), @el
            #Assert
            doh.assertEqual @el, dom.find("#div1").next()[0]
            doh.assertEqual @el, dom.find("#div3").prev()[0]
        tearDown: () ->
            dom.destroy @parent
    ,
        name: "register_idAndObject_objectIsRegistered"
        setUp: () ->
            #Arrange
            dom.unregister "dummy"
            @obj = {foo:"bar"}
        runTest: (t) -> 
            #Act
            dom.register "dummy", @obj
            #Assert
            doh.assertEqual @obj, window.U4.__registry.dummy
        tearDown: () ->
            dom.unregister "dummy"
    ,
        name: "register_sameIdTwice_throws"
        setUp: () ->
            #Arrange
            @obj = {foo:"bar"}
        runTest: (t) -> 
            #Act
            dom.register "dummy", @obj
            #Assert
            doh.assertError Exception, dom, "register", ["dummy", @obj]
        tearDown: () ->
            dom.unregister "dummy"
    ,
        name: "unregister_id_objectIsUnregistered"
        setUp: () ->
            #Arrange
            @obj = {foo:"bar"}
            dom.register "dummy", @obj
        runTest: (t) -> 
            #Act
            dom.unregister "dummy"
            #Assert
            doh.assertEqual undefined, window.U4.__registry.dummy
    ,
        name: "unregisterWidget_existingWidgetId_widgetIsRemoved"
        setUp: () ->
            #Arrange
            dijit.registry.add {id: "fakeWidget"}
        runTest: (t) -> 
            #Act
            dom.unregisterWidget "fakeWidget"
            #Assert
            doh.assertEqual undefined, dijit.registry.byId "fakeWidget"
    ]
