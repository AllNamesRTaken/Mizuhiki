define [
    "dojo/main"
    "util/doh/main"
    "clazzy/Clazzy"
    "dojo/cache"
    "dojo/_base/url"
    "mizuhiki/abstraction/Lang" #used for event
    "mizuhiki/abstraction/Dom" #used for byid,findAllWidgets,unregisterWidget,unregister,parse,create,place,find,register,destroy
    "mizuhiki/Mizuhiki"
    "clazzy/Exception"
    "mizuhiki/TemplatedObject"
    "mizuhiki/SoyaMilk" 
], (dojo, doh, Class, cache, _url, lang, dom, Mizuhiki, Exception, TemplatedObject, soyamilk) ->

    renderer = new Mizuhiki()
    DummyClass = Class("namespace.Dummy", null, [null])
    TemplatedDummyClass = Class("namespace.TemplatedDummy", TemplatedObject, null, 
        constructor: () ->
            @AttachPoint = document.body
            this
    )

    doh.register "mizuhiki.tests.Mizuhiki", [ 

        name: "render_control_callsDraw"
        setUp: () ->
            #Arrange
            renderer._drawCalled = false
            @original_draw = renderer._draw
            renderer._draw = (control, id, index, data) ->
                this._drawCalled = true
        runTest: (t) -> 
            #Act
            renderer.render("dummy")
            #Assert
            doh.assertTrue(renderer._drawCalled)
        tearDown: () ->
            renderer._draw = @original_draw
    ,
        name: "_draw_control_allPartsCalled"
        setUp: () ->
            # The mother of all mocking!
            renderer._unbindDataCalled = false
            @original_unbindData = renderer._unbindData
            renderer._unbindData = (control, nodeId) ->
                control._dataBindings = {parsed: false} # just resetting so that later tests with pass
                this._unbindDataCalled = "_unbindDataCalled"

            renderer._removeWidgetsCalled = false
            @original_removeWidgets = renderer._removeWidgets    #Dojo specifics, destroyRecursive
            renderer._removeWidgets = (control, nodeId) ->
                this._removeWidgetsCalled = "_removeWidgetsCalled"

            renderer._unregisterNodeCalled   = false
            @original_unregisterNode = renderer._unregisterNode
            renderer._unregisterNode = (control) ->
                this._unregisterNodeCalled = "_unregisterNodeCalled"

            renderer._calculateBindingsCalled = false
            @original_calculateBindings = renderer._calculateBindings
            renderer._calculateBindings = (control) ->
                this._calculateBindingsCalled = "_calculateBindingsCalled"

            renderer._parseTemplateCalled = false
            @original_parseTemplate = renderer._parseTemplate
            renderer._parseTemplate = (control, id, index, data) ->
                this._parseTemplateCalled = "_parseTemplateCalled"

            renderer.__frameworkReplaceCustomAttributesCalled = false
            @original__frameworkReplaceCustomAttributes = renderer.__frameworkReplaceCustomAttributes    #Dojo specifics 
            renderer.__frameworkReplaceCustomAttributes = (html) ->
                this.__frameworkReplaceCustomAttributesCalled = "__frameworkReplaceCustomAttributesCalled"

            renderer._placeHtmlCalled = false
            @original_placeHtml = renderer._placeHtml
            renderer._placeHtml = (control, html, nodeId) ->
                this._placeHtmlCalled = "_placeHtmlCalled"

            renderer._registerNodeCalled = false
            @original_registerNode = renderer._registerNode
            renderer._registerNode = (control) ->
                this._registerNodeCalled = "_registerNodeCalled"

            renderer.__frameworkParseCalled = false
            @original__frameworkParse = renderer.__frameworkParse 
            renderer.__frameworkParse = (dom) ->
                this.__frameworkParseCalled = "__frameworkParseCalled"

            renderer._runGeneratorsCalled = false
            @original_runGenerators = renderer._runGenerators 
            renderer._runGenerators = (dom) ->
                this._runGeneratorsCalled = "_runGeneratorsCalled"

            renderer._bindDataCalled = false
            @original_bindData = renderer._bindData 
            renderer._bindData = (control, nodeId, dom) ->
                this._bindDataCalled = "_bindDataCalled"

            renderer._cleanDomCalled = false
            @original_cleanDom = renderer._cleanDom    #Arrange
            renderer._cleanDom = (dom) ->
                this._cleanDomCalled = "_cleanDomCalled"
        runTest: (t) -> 
            dummyControl = new TemplatedDummyClass()
            #Act
            renderer._draw(dummyControl)
            #Assert
            doh.assertEqual("_unbindDataCalled", renderer._unbindDataCalled)
            doh.assertEqual("_removeWidgetsCalled", renderer._removeWidgetsCalled)
            doh.assertEqual("_unregisterNodeCalled", renderer._unregisterNodeCalled)
            doh.assertEqual("_calculateBindingsCalled", renderer._calculateBindingsCalled)
            doh.assertEqual("_parseTemplateCalled", renderer._parseTemplateCalled)
            doh.assertEqual("__frameworkReplaceCustomAttributesCalled", renderer.__frameworkReplaceCustomAttributesCalled)
            doh.assertEqual("_placeHtmlCalled", renderer._placeHtmlCalled)
            doh.assertEqual("_registerNodeCalled", renderer._registerNodeCalled)
            doh.assertEqual("__frameworkParseCalled", renderer.__frameworkParseCalled)
            doh.assertEqual("_runGeneratorsCalled", renderer._runGeneratorsCalled)
            doh.assertEqual("_bindDataCalled", renderer._bindDataCalled)
            doh.assertEqual("_cleanDomCalled", renderer._cleanDomCalled)
        tearDown: () ->
            renderer._unbindData = @original_unbindData
            renderer._removeWidgets = @original_removeWidgets
            renderer._unregisterNode = @original_unregisterNode
            renderer._calculateBindings = @original_calculateBindings
            renderer._parseTemplate = @original_parseTemplate
            renderer.__frameworkReplaceCustomAttributes = @original__frameworkReplaceCustomAttributes
            renderer._placeHtml = @original_placeHtml
            renderer._registerNode = @original_registerNode
            renderer.__frameworkParse = @original__frameworkParse
            renderer._runGenerators = @original_runGenerators
            renderer._bindData = @original_bindData
            renderer._cleanDom = @original_cleanDom
    ,
        name: "generateGuid_null_generates32CharGuid"
        setUp: () ->
            #Arrange
        runTest: (t) -> 
            #Act
            guid = renderer.generateGuid();
            #Assert
            doh.assertTrue guid.length is 32
        tearDown: () ->
    ,
        name: "generateGuid_null_generatesDifferent"
        setUp: () ->
            #Arrange
        runTest: (t) -> 
            #Act
            guid1 = renderer.generateGuid();
            guid2 = renderer.generateGuid();
            #Assert
            doh.assertNotEqual guid1, guid2
        tearDown: () ->
    ,
        name: "_unbindData_control_unbindsEvents"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control._setterBindings._domHandle = "domhandle"
            @control._attachPoints = {"id1": "attachPoint1", "id2": "attachPoint2"}
            @control._attachEvents = {"id1": ["handle1", "handle2"], "id2": ["handle3", "handle4"]}
            @control.PreviousId = "someid"

            @control._attachIds["someid"] = {"id1": true, "id2": true}

            @target = ["setterhandle", "domhandle", "handle1", "handle2", "handle3", "handle4"]
            @originalById = dom.byId
            dom.byId = (id) -> 
                document.createElement("div")
        runTest: (t) -> 
            disconnected = []
            @originalEventRemove = lang.event.remove
            lang.event.remove = (handle) ->
                disconnected.push handle
            @control._setterBindings._setterHandle = 
                remove: () ->
                    disconnected.push "setterhandle"
            #Act
            renderer._unbindData(@control)
            #Assert
            doh.assertEqual(@target, disconnected)
        tearDown: () ->
            dom.byId = @originalById
            lang.event.remove = @originalEventRemove
    ,
        name: "_removeWidgets_control_unregisterAndDestroyWidget"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.PreviousId = "someid"
        runTest: (t) -> 
            destroyed = []
            unregistered = false
            @originalFindAllWidgets = dom.findAllWidgets
            dom.findAllWidgets = (id) -> 
                    [{destroyRecursive: () -> destroyed.push(1)},{destroyRecursive: () -> destroyed.push(2)}]
            @originalUnregisterWidget = dom.unregisterWidget
            dom.unregisterWidget = (id) -> 
                unregistered = true
            #Act
            renderer._removeWidgets(@control)
            #Assert
            doh.assertEqual([1,2], destroyed)
            doh.assertTrue unregistered
        tearDown: () ->
            dom.findAllWidgets = @originalFindAllWidgets
            dom.unregisterWidget = @originalUnregisterWidget
    ,
        name: "_removeWidgets_control_unregisteredAndDestroyed"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.PreviousId = "someid"
        runTest: (t) -> 
            unregistered = false
            @originalUnregister = dom.unregister
            dom.unregister = (id) -> 
                    unregistered = true
            #Act
            renderer._unregisterNode(@control)
            #Assert
            doh.assertTrue unregistered
        tearDown: () ->
            dom.unregister = @originalUnregister
    ,
        name: "_calculateBindings_control_correctDataBindingsAndSetterBindings"
        setUp: () ->
            #Arrange
            @originalRender = soyamilk.render
            soyamilk.render =(itemId, control, partials) -> 
                itemId.replace(/{{Id}}/g, "someid")

            url = "../../mizuhiki/tests/resources/DummyTemplate.html"
            @control = new TemplatedDummyClass();
            @control.Id = "someid"
            @control.templateString = cache new _url(url)
            @expectedDataBindings = {"someid_input":{"html":"<input type=\"text\" value=\"{{Text}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}_input\" data-bind-to=\"Text\">","prop":["Text"],"key":null},"someid_LastUpdated":{"html":"<span id=\"{{Id}}_LastUpdated\" data-bind-to=\"Text\">{{Text}}</span>","prop":["Text"],"key":null},"someidarrText{{_}}":{"html":"<input type=\"text\" value=\"{{data}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}arrText{{_}}\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=\"{{_}}\">","prop":["DataArray"],"key":"data"},"someidarrSpan{{_}}":{"html":"<span id=\"{{Id}}arrSpan{{_}}\" data-bind-to=\"DataArray\" data-index=\"{{_}}\">{{data}}</span>","prop":["DataArray"],"key":null},"parsed":true}
            @expectedSetterBindings = {"Text":["someid_input","someid_LastUpdated"],"DataArray":["someidarrText{{_}}","someidarrSpan{{_}}"]}
        runTest: (t) -> 
            #Act
            renderer._calculateBindings(@control)
            #Assert
            doh.assertEqual(@expectedDataBindings.someid_LastUpdated, this.control._dataBindings.someid_LastUpdated)
            exp_input = dom.create(@expectedDataBindings.someid_input.html)
            input = dom.create(@control._dataBindings.someid_input.html)
            doh.assertEqual(exp_input.getAttribute("type"), input.getAttribute("type"))
            doh.assertEqual(exp_input.getAttribute("value"), input.getAttribute("value"))
            doh.assertEqual(exp_input.getAttribute("data-dojo-type"), input.getAttribute("data-dojo-type"))
            doh.assertEqual(exp_input.getAttribute("data-dojo-props"), input.getAttribute("data-dojo-props"))
            doh.assertEqual(exp_input.getAttribute("id"), input.getAttribute("id"))
            doh.assertEqual(exp_input.getAttribute("data-bind-to"), input.getAttribute("data-bind-to"))
            doh.assertEqual(exp_input.innerHTML, input.innerHTML)
            doh.assertEqual(@expectedDataBindings["someidarrSpan{{_}}"], this.control._dataBindings["someidarrSpan{{_}}"])
            doh.assertEqual(@expectedDataBindings["someidarrText{{_}}"], this.control._dataBindings["someidarrText{{_}}"])
            doh.assertEqual(@expectedSetterBindings, this.control._setterBindings)
        tearDown: () ->
            soyamilk.render = @originalRender
    ,
        name: "_parseTemplate_control_soyaMilkRenderCalled"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
        runTest: (t) -> 
            soyamilkcalled = false
            @originalRender = soyamilk.render
            soyamilk.render =(template, data, partials) -> 
                soyamilkcalled = true
                "dummyString"
            #Act
            renderer._parseTemplate(@control)
            #Assert
            doh.assertTrue soyamilkcalled
        tearDown: () ->
            soyamilk.render = @originalRender
    ,
        name: "_parseTemplate_IdIndexData_soyaMilkRenderCalled"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.Id = "someid"
            @id = @control.Id + "arrText{{_}}"
            @index = 1
            @data = {DataArray: "sometext"}
            @control._dataBindings = {"someid_input":{"html":"<input type=\"text\" value=\"{{Text}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}_input\" data-bind-to=\"Text\">","prop":["Text"],"key":null},"someid_LastUpdated":{"html":"<span id=\"{{Id}}_LastUpdated\" data-bind-to=\"Text\">{{Text}}</span>","prop":["Text"],"key":null},"someidarrText{{_}}":{"html":"<input type=\"text\" value=\"{{data}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}arrText{{_}}\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=\"{{_}}\">","prop":["DataArray"],"key":"data"},"someidarrSpan{{_}}":{"html":"<span id=\"{{Id}}arrSpan{{_}}\" data-bind-to=\"DataArray\" data-index=\"{{_}}\">{{data}}</span>","prop":["DataArray"],"key":null},"parsed":true}
            @control._setterBindings = {"Text":["someid_input","someid_LastUpdated"],"DataArray":["someidarrText{{_}}","someidarrSpan{{_}}"]}
            @expectedTemplateString = "<input type=\"text\" value=\"{{data}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}arrText1\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=\"1\">"
        runTest: (t) -> 
            templateString = ""
            @originalRender = soyamilk.render
            soyamilk.render =(template, data, partials) -> 
                templateString = template
            #Act
            renderer._parseTemplate(@control, @id, @index, @data)
            #Assert
            doh.assertEqual @expectedTemplateString, templateString
        tearDown: () ->
            soyamilk.render = @originalRender
    ,
        name: "__frameworkReplaceCustomAttributes_string_dojoAttributesReplaced"
        setUp: () ->
            #Arrange
            @text = "blabla data-dojo-attach blabla"
            @targetText = "blabla data-cleaned-attach blabla"
        runTest: (t) -> 
            #Act
            text = renderer.__frameworkReplaceCustomAttributes(@text)
            #Assert
            doh.assertEqual(@targetText, text)
        tearDown: () ->
    ,
        name: "__frameworkParse_dom_parseCalled"
        setUp: () ->
            #Arrange
            @dom = document.createElement("div");
        runTest: (t) -> 
            parseCalled = false
            @originalParse = dom.parse
            dom.parse =(dom) -> 
                parseCalled = true
            #Act
            renderer.__frameworkParse(@dom)
            #Assert
            doh.assertTrue(parseCalled)
        tearDown: () ->
            dom.parse = @originalParse
    ,
        name: "_runGenerators_controlAndNode_domReplacedWithResultFromGenerator"
        setUp: () ->
            #Arrange
            @node = document.createElement("div");
            @node.innerHTML = '<div></div><span data-generator-function="makeit"></span><div></div>'
            @control = 
                makeit: () ->
                    el = document.createElement("span")
                    el.innerHTML = "madeit"
                    el
            @expected = '<div></div><span>madeit</span><div></div>'
        runTest: (t) -> 
            #Act
            renderer._runGenerators(@control, @node)
            #Assert
            doh.assertEqual @expected, @node.innerHTML
        tearDown: () ->
    ,
        name: "__frameworkParse_domWithAttribute_parseCalledWithParent"
        setUp: () ->
            #Arrange
            @parent = document.createElement("div");
            @node = document.createElement("div");
            @node.setAttribute("data-dojo-type", "somevalue")
            @parent.appendChild(@node)
        runTest: (t) -> 
            parseCalled = false
            @originalParse = dom.parse
            parent = @parent
            dom.parse = (node) -> 
                parseCalled = node is parent
            #Act
            renderer.__frameworkParse(@node)
            #Assert
            doh.assertTrue(parseCalled)
        tearDown: () ->
            dom.parse = @originalParse
    ,
        name: "_placeHtml_controlHtmlId_htmlReplaced"
        setUp: () ->
            #Arrange
            @control = new DummyClass();
            @control.PreviousId = "previd"
            @control.AttachPoint = "someAttachPoint"
            @control.PreviousAttachPoint = "someAttachPoint"
            @templateHtml = "<input type=\"text\" value=\"{{data}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}arrText1\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=\"1\">"
            @id = "someid"

        runTest: (t) -> 
            #mock
            createdElement = document.createElement("div")
            @originalCreate = dom.create
            dom.create = (html) -> 
                createdElement

            @originalById = dom.byId
            dom.byId = (id) -> 
                "someAttachPoint"

            placedNode = null
            placedId = null
            placedHow = null
            @originalPlace = dom.place
            dom.place = (node, domOrId, position) -> 
                placedNode = node
                placedId = domOrId
                placedHow = position
            #Act
            renderer._placeHtml(@control, @templateHtml, @id)
            #Assert
            doh.assertEqual(createdElement, placedNode)
            doh.assertEqual("widget_someid", placedId)
            doh.assertEqual("replace", placedHow)
        tearDown: () ->
            dom.create = @originalCreate
            dom.byId = @originalById
            dom.place = @originalPlace
    ,
        name: "_placeHtml_controlHtml_htmlReplaced"
        setUp: () ->
            #Arrange
            @control = new DummyClass();
            @control.PreviousId = "previd"
            @control.AttachPoint = "someAttachPoint"
            @control.PreviousAttachPoint = "someAttachPoint"
            @templateHtml = "dummyTemplateString"

        runTest: (t) -> 
            #mock
            createdElement = document.createElement("div")
            @originalCreate = dom.create
            dom.create = (html) -> 
                createdElement

            @originalById = dom.byId
            dom.byId = (id) -> 
                "someAttachPoint"

            placedNode = null
            placedId = null
            placedHow = null
            @originalPlace = dom.place
            dom.place = (node, domOrId, position) -> 
                placedNode = node
                placedId = domOrId
                placedHow = position
            #Act
            renderer._placeHtml(@control, @templateHtml)
            #Assert
            doh.assertEqual(createdElement, placedNode)
            doh.assertEqual(@control.PreviousId, placedId)
            doh.assertEqual("replace", placedHow)
        tearDown: () ->
            dom.create = @originalCreate
            dom.byId = @originalById
            dom.place = @originalPlace
    ,
        name: "_placeHtml_controlHtmlNoPreviousId_htmlPlacedAtAttachPoint"
        setUp: () ->
            #Arrange
            @control = new DummyClass();
            @control.AttachPoint = "someAttachPoint"
            @templateHtml = "dummyTemplateString"

        runTest: (t) -> 
            #mock
            createdElement = document.createElement("div")
            @originalCreate = dom.create
            dom.create = (html) -> 
                createdElement

            @originalById = dom.byId
            dom.byId = (id) -> 
                if id is "someAttachPoint" then "someAttachPoint" else true

            placedNode = null
            placedId = null
            placedHow = null
            @originalPlace = dom.place
            dom.place = (node, domOrId, position) -> 
                placedNode = node
                placedId = domOrId
                placedHow = position
            #Act
            renderer._placeHtml(@control, @templateHtml)
            #Assert
            doh.assertEqual(createdElement, placedNode)
            doh.assertEqual( @control.AttachPoint, placedId)
            doh.assertEqual(undefined, placedHow)
        tearDown: () ->
            dom.create = @originalCreate
            dom.byId = @originalById
            dom.place = @originalPlace
    ,
        name: "_placeHtml_controlHtmlNoAttachPoint_nodeCreatedAndDomRemoved"
        setUp: () ->
            #Arrange
            @control = new DummyClass();
            @control.AttachPoint = null
            @control.PreviousAttachPoint = "someAttachPoint"
            @templateHtml = "dummyTemplateString"

        runTest: (t) -> 
            #mock
            createdElement = document.createElement("div")
            @originalCreate = dom.create
            dom.create = (html) -> 
                createdElement

            @originalById = dom.byId
            dom.byId = (id) -> 
                true

            domDestroyed = false
            @originalDestroy = dom.destroy
            dom.destroy = (id) -> 
                domDestroyed = "domDestroyed"

            placeCalled = false
            @originalPlace = dom.place
            dom.place = (node, domOrId, position) -> 
                placeCalled = "placeCalled"
            #Act
            doh.assertEqual undefined, @control.domNode

            renderer._placeHtml(@control, @templateHtml)
            #Assert
            doh.assertEqual(false, placeCalled)
            doh.assertEqual("domDestroyed", domDestroyed)
            doh.assertTrue @control.domNode
        tearDown: () ->
            dom.create = @originalCreate
            dom.byId = @originalById
            dom.place = @originalPlace
            dom.destroy = @originalDestroy
    ,
        name: "_registerNode_control_registerCalled"
        setUp: () ->
            #Arrange
            @control = new DummyClass();
        runTest: (t) -> 
            registerCalled = false
            @originalRegister = dom.register
            dom.register =(dom) -> 
                registerCalled = true
            #Act
            renderer._registerNode(@control)
            #Assert
            doh.assertTrue(registerCalled)
        tearDown: () ->
            dom.register = @originalRegister
    ,
        name: "_bindData_controlAndDom_dataOnchangeAndSetterBound"
        setUp: () ->
            #Arrange
            @control = new DummyClass();
            @control.DataArray = [{data: "text1"}, {data: "text2"}]
            @control.Id = "someid"
            @control._dataBindings = 
                {
                    "someid_input": {
                        "html": "<input type=\"text\" value=\"{{Text}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}_input\" data-bind-to=\"Text\">",
                        "prop": ["Text"],
                        "key": null
                    },
                    "someid_LastUpdated": {
                        "html": "<span id=\"{{Id}}_LastUpdated\" data-bind-to=\"Text\">{{Text}}</span>",
                        "prop": ["Text"],
                        "key": null
                    },
                    "someidarrText{{_}}": {
                        "html": "<input type=\"text\" value=\"{{data}}\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"{{Id}}arrText{{_}}\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=\"{{_}}\">",
                        "prop": ["DataArray"],
                        "key": "data"
                    },
                    "someidarrSpan{{_}}": {
                        "html": "<span id=\"{{Id}}arrSpan{{_}}\" data-bind-to=\"DataArray\" data-index=\"{{_}}\">{{data}}</span>",
                        "prop": ["DataArray"],
                        "key": null
                    },
                    "parsed": true
                }
            @control._setterBindings = {"Text":["someid_input","someid_LastUpdated"],"DataArray":["someidarrText{{_}}","someidarrSpan{{_}}"]}
            @control._attachIds = {someid: {"id1": true, "id2": true}}
            html = 
                "<div id=\"someid\" class=\"Text\" width: 100%; height: 100%\">
                    <input type=\"text\" value=\"sometext\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someid_input\" data-bind-to=\"Text\" />
                    <label for=\"someid_input\">
                        <span id=\"someid_LastUpdated\" data-bind-to=\"Text\">sometext</span> 
                    </label>
                    <br />
                        <input type=\"text\" value=\"text1\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someidarrText0\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=0 />
                        <label for=\"someidarrText0\">
                            <span id=\"someidarrSpan0\" data-bind-to=\"DataArray\" data-index=0>text1</span> 
                        </label>
                        <br />
                        <input type=\"text\" value=\"text2\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someidarrText1\" data-bind-to=\"DataArray\" data-bind-to-key=\"data\" data-index=1 />
                        <label for=\"someidarrText1\">
                            <span id=\"someidarrSpan1\" data-bind-to=\"DataArray\" data-index=1>text2</span> 
                        </label>
                        <br />
                </div>"
            @node = dom.create html
            @evt = {target: dom.create("<input type=\"text\" value=\"somenewvalue\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someid_input\" data-bind-to=\"Text\" />")}
        runTest: (t) -> 
            _bindEventsCalled = false
            @original_bindEvents = renderer._bindEvents
            renderer._bindEvents = (control, dom, nodeId) -> 
                _bindEventsCalled = "_bindEventsCalled"

            _bindAttachPointsCalled = false
            @original_bindAttachPoints = renderer._bindAttachPoints
            renderer._bindAttachPoints = (control, dom, nodeId) -> 
                _bindAttachPointsCalled = "_bindAttachPointsCalled"

            connectCalled = []
            @originalOn = lang.event.on
            lang.event.on = (obj, event, context, method, dontFix) -> 
                connectCalled.push event

            @originalWatch = @control.watch
            @control.watch = (prop, callback) -> 
                connectCalled.push "set"

            setCalled = []
            @originalSet = @control.set
            @control.set = (prop, value, index, self) -> 
                setCalled.push prop

            #Act
            renderer._bindData(@control, @id, @node)

            #Assert
            doh.assertEqual("_bindEventsCalled", _bindEventsCalled)
            doh.assertEqual("_bindAttachPointsCalled", _bindAttachPointsCalled)
            doh.assertEqual(["set", "change"], connectCalled)
        tearDown: () ->
            renderer._bindEvents = @original_bindEvents
            renderer._bindAttachPoints = @original_bindAttachPoints
            lang.event.on = @originalOn
            @control.watch = @originalWatch
    ,
        name: "_bindEvents_controlNodeNodeId_eventBoundAndAttachIdsSet"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.Id = "someid"
            html = 
                "<div id=\"someid\" class=\"Text\" width: 100%; height: 100%\">
                    <input type=\"text\" value=\"sometext\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someid_input\" data-cleaned-attach-event=\"change:somehandler\" />
                    <label for=\"someid_input\">
                        <span id=\"someid_LastUpdated\" data-bind-to=\"Text\">sometext</span> 
                    </label>
                </div>"
            @node = dom.create html
            @subnode = dom.find("input", @node)[0]
        runTest: (t) -> 
            somehandlerCalled = false
            @control.somehandler = () -> 
                somehandlerCalled = true
            #Act
            renderer._bindEvents(@control, @node, "someid")
            lang.event.emit @subnode, "change"
            #Assert
            doh.assertTrue @control._attachIds["someid"]["someid_input"]
            doh.assertTrue somehandlerCalled
        tearDown: () ->
    ,
        name: "_bindEvents_controlNodeNodeId_eventBoundAndAttachIdsSet"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.Id = "someid"
            html = 
                "<div id=\"someid\" class=\"Text\" width: 100%; height: 100%\">
                    <input type=\"text\" value=\"sometext\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someid_input\" data-cleaned-attach-point=\"somePoint\" />
                    <label for=\"someid_input\">
                        <span id=\"someid_LastUpdated\" data-bind-to=\"Text\">sometext</span> 
                    </label>
                </div>"
            @node = dom.create html
            @subnode = dom.find("input", @node)[0]
        runTest: (t) -> 
            #Act
            renderer._bindAttachPoints(@control, @node, "someid")
            #Assert
            doh.assertTrue @control._attachIds["someid"]["someid_input"]
            doh.assertEqual @subnode, @control.somePoint
        tearDown: () ->
    ,
        name: "_cleanDom_node_cleaned"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.Id = "someid"
            html = 
                "<div id=\"someid\" class=\"Text\" width: 100%; height: 100%\">
                    <input type=\"text\" value=\"sometext\" data-dojo-type=\"dijit.form.TextBox\" data-dojo-props=\"trim:true, propercase:true\" id=\"someid_input\" />
                    <label for=\"someid_input\">
                        <span id=\"someid_LastUpdated\" data-bind-to=\"Text\">sometext</span> 
                    </label>
                </div>"
            @node = dom.create html
        runTest: (t) -> 
            #Act
            renderer._cleanDom(@node)
            #Assert
            findArray = dom.find '[data-dojo-type]', @node 
            doh.assertEqual 0, findArray.length
        tearDown: () ->
    ,
        name: "destroy_control_controlUiDestroyedAndUnregistered"
        setUp: () ->
            #Arrange
            @control = new TemplatedDummyClass();
            @control.Id = "someid"
            @control._setterBindings = {_setterHandle: "_setterHandle", _domHandle: "_domHandle"}

        runTest: (t) -> 
            watchRemoveCalled = false
            @control._setterBindings._setterHandle = 
                remove: () ->
                    watchRemoveCalled = "watchRemoveCalled"

            eventRemoveCalled = false
            @originalEventRemove = lang.event.remove
            lang.event.remove = (handle) -> 
                eventRemoveCalled = "eventRemoveCalled"

            _unbindDataCalled = false
            @original_unbindData = renderer._unbindData
            renderer._unbindData = (control) -> 
                _unbindDataCalled = "_unbindDataCalled"

            _removeWidgets = false
            @original_removeWidgets = renderer._removeWidgets
            renderer._removeWidgets = (control) -> 
                _removeWidgets = "_removeWidgets"

            _unregisterNodeCalled = false
            @original_unregisterNode = renderer._unregisterNode
            renderer._unregisterNode = (control) -> 
                _unregisterNodeCalled = "_unregisterNodeCalled"

            domDestroyCalled = false
            @originalDomDestroy = dom.destroy
            dom.destroy = (Id) -> 
                domDestroyCalled = "domDestroyCalled"
            #Act
            renderer.destroy(@control)
            #Assert
            doh.assertEqual "watchRemoveCalled", watchRemoveCalled
            doh.assertEqual "eventRemoveCalled", eventRemoveCalled
            doh.assertEqual "_unbindDataCalled", _unbindDataCalled
            doh.assertEqual "_removeWidgets", _removeWidgets
            doh.assertEqual "_unregisterNodeCalled", _unregisterNodeCalled
            doh.assertEqual "domDestroyCalled", domDestroyCalled
        tearDown: () ->
            lang.event.remove = @originalEventRemove
            renderer._unbindData = @original_unbindData
            renderer._removeWidgets = @original_removeWidgets
            renderer._unregisterNode = @original_unregisterNode
            dom.destroy = @originalDomDestroy

    ]
