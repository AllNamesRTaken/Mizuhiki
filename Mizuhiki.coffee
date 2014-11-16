define [
    "clazzy/Clazzy"
    "mizuhiki/abstraction/Lang" #used for event (on),trim,clone
    "mizuhiki/abstraction/Dom" #used for byId,findAllWidgets,unregister,unregisterWidget,create,find,parse,place,register,destroy
    "mizuhiki/SoyaMilk" #Mustache in Coffeescript -> Milk, Milk + AMD + MVVM fairy dust -> SoyaMilk
    "clazzy/Exception"
    "mizuhiki/TemplatedObject"
], ( Class, lang, dom, soyamilk, Exception, TemplatedObject) ->
    'use strict'

    Class "mizuhiki.Mizuhiki", null, null, 

        render: (control) -> 
            @_draw control
        
        # Private Functions
        _draw: (control, id, index, data) -> 
            throw new Exception("IllegalObjectException", "Control isnt a templated object. Missing IRendererMeta.") if control?.haznt "IRendererMeta"
            control.set "Id", control.get("Id") or @generateGuid()
            console.warn("No AttachPoint set on control " + control.get("Id") + ". Control wont be visible.") if not control.get("AttachPoint")
            nodeId = id.replace "{{_}}", index if id
            nodeId = nodeId.replace "{{Id}}", id if id
            if nodeId and not control.domNode.querySelector?("#"+nodeId)
                index = undefined
                nodeId = undefined
                id = undefined
            @_unbindData control, nodeId
            @_removeWidgets control, nodeId    #Dojo specifics, destroyRecursive
            @_unregisterNode control if not id
            @_calculateBindings control if not control.IRendererMeta._dataBindings.parsed
            html = @_parseTemplate control, id, index, data
            html = @__frameworkReplaceCustomAttributes html    #Dojo specifics 
            node = @_placeHtml control, html, nodeId
            node.id = control.get("Id") if not id
            @_registerNode control if not id
            @__frameworkParse node
            @_runGenerators control, node
            @_bindData control, nodeId, node if control.get("AttachPoint")
            @_cleanDom node
            control.set "PreviousId", control.get("Id")
            control.set "PreviousAttachPoint", control.get("AttachPoint")

        generateGuid: (withDash = false, checkForNodes = true) ->
            d = if withDash then "-" else ""
            S4 = () ->
                (((1+Math.random())*0x10000)|0).toString(16).substring(1)
            guid = (S4()+S4()+d+S4()+d+S4()+d+S4()+d+S4()+S4()+S4())
            while checkForNodes and dom.byId(guid)
                guid = (S4()+S4()+d+S4()+d+S4()+d+S4()+d+S4()+S4()+S4())
            guid

        _unbindData: (control, id) -> 
            nodeId = id or control.get("PreviousId") or control.get("Id")
            return if not nodeId
            node = dom.byId nodeId
            return if not node
            #Only proceed if the control has a rendered UI
            if not id
                #If _drawing the entire control and not a subsection disconnect connection for setters as well as for the onchange on the domNode
                if control.IRendererMeta._setterBindings._setterHandle 
                    control.IRendererMeta._setterBindings._setterHandle.remove()
                    control.IRendererMeta._setterBindings._setterHandle = null
                if control.IRendererMeta._setterBindings._domHandle
                    lang.event.remove control.IRendererMeta._setterBindings._domHandle
                    control.IRendererMeta._setterBindings._domHandle = null
            for key of control.IRendererMeta._attachIds[nodeId]
                #disconnect all events attached through the template and remove all pointers to attachpoints and events
                lang.event.remove(handle) for handle in control.IRendererMeta._attachEvents[key] if key of control.IRendererMeta._attachEvents
                control.IRendererMeta._attachPoints[key]? and delete control[control.IRendererMeta._attachPoints[key]]
                control.IRendererMeta._attachPoints[key]? and delete control.IRendererMeta._attachPoints[key]
                control.IRendererMeta._attachEvents[key]? and delete control.IRendererMeta._attachEvents[key]
                delete control.IRendererMeta._attachIds[control.get("PreviousId") or control.get("Id")][key]
            delete control.IRendererMeta._attachIds[nodeId]
            undefined

        _removeWidgets: (control, id) -> 
            nodeId = id or control.get("PreviousId") or control.get("Id")
            return if not nodeId
            node.destroyRecursive() for node in dom.findAllWidgets(nodeId)
            dom.unregisterWidget(nodeId)

        _unregisterNode: (control) -> 
            dom.unregister(control.get("PreviousId") or control.get("Id"))
        
        _calculateBindings: (control) ->
            #This function parses the templateString with respect to its data bindings.
            #The result is stored in _dataBindings and _setterBindings.
            #databindings map id of the html element to the property that controls is, and if the property is an object array, a key in this object.
            #setterbindings is a reverse of the databindings, mapping property name to an array of the controls that should be updated when it changes.
            outerHTML = (node) ->
                return node.outerHTML || (
                    (n) -> 
                        div = document.createElement('div')
                        div.appendChild n.cloneNode(true)
                        h = div.innerHTML
                        div = null
                        return h
                    )(node)
            templateDom = dom.create control.get("templateString")
            div = dom.create "<div></div>"
            div.appendChild templateDom
            databound = dom.find '[data-bind-to]', div
            if databound.length > 0
                for i in [0..databound.length-1]
                    itemId = databound[i].id.replace "{{_}}", "_____"
                    itemId = lang.trim(soyamilk.render(itemId, control, control.partials or= {})).replace "_____", "{{_}}"
                    control.IRendererMeta._dataBindings[itemId] = 
                        html: outerHTML(databound[i])
                        prop: lang.map(databound[i].getAttribute('data-bind-to').split(','), (el) ->
                            lang.trim(el)
                        )
                        key: databound[i].getAttribute('data-bind-to-key')
                    for prop in control.IRendererMeta._dataBindings[itemId].prop
                        control.IRendererMeta._setterBindings[prop] = [] if not control.IRendererMeta._setterBindings[prop]
                        control.IRendererMeta._setterBindings[prop].push itemId
            control.IRendererMeta._dataBindings.parsed = true
        
        _parseTemplate: (control, id, index, data) -> 
            if !id?
                return lang.trim(soyamilk.render(control.get("templateString"), control, control.partials or= {}))
            templateString = if index? then control.IRendererMeta._dataBindings[id].html.replace(/{{_}}/g, index) else control.IRendererMeta._dataBindings[id].html
            if index
                for key, value of data
                    regex = new RegExp "{{"+key+"}}"
                    templateString = templateString.replace(regex, value)
            lang.trim(soyamilk.render(templateString, control, control.partials or= {}))

        __frameworkReplaceCustomAttributes: (html) -> 
            html = html.replace(/data-dojo-attach/gi, "data-attach");

        __frameworkParse: (node) -> 
            if node.parentNode and node.attributes["data-dojo-type"] isnt undefined
                dom.parse(node.parentNode)
            else
                dom.parse(node)
        _runGenerators: (control, node) ->
            try
                for generatorNode in dom.find "[data-generator-function]", node
                    if (f = control[generatorName = generatorNode.getAttribute("data-generator-function")]).call?
                        dom.replace generatorNode, f.call(control)
                        control[generatorName + "Startup"]() if control[generatorName + "Startup"]?
            catch err
                throw new Exception("GeneratorException", "Generator '" + generatorName + "' was not found on " + control.get("declaredClass") + " or it markup was invalid")

        _placeHtml: (control, html, id) -> 
            nodeId = id or control.get("PreviousId")
            domNode = dom.create(html)
            widgetId = "widget_" + id if dom.byId("widget_" + id)
            idPassed = nodeId is id
            attachPoint = control.get("AttachPoint")
            if "string" is typeof attachPoint
                attachPoint = if attachPoint is "body" then document.body else dom.byId(attachPoint)
            prevAttachPoint = control.get("PreviousAttachPoint")
            if "string" is typeof prevAttachPoint
                prevAttachPoint = if prevAttachPoint is "body" then document.body else dom.byId(prevAttachPoint)

            removeDom = (not attachPoint? and prevAttachPoint?) or (attachPoint? and prevAttachPoint? and attachPoint isnt prevAttachPoint)
            replaceDom = prevAttachPoint? and attachPoint is prevAttachPoint
            placeNewDom = attachPoint? and not replaceDom
            
            if removeDom
                dom.destroy control.get("Id")
            if replaceDom
                dom.replace((if idPassed then widgetId or nodeId else control.get("PreviousId")), domNode)
            if placeNewDom
                dom.place(domNode, attachPoint)
            if not id
                control.domNode = domNode
            domNode

        _registerNode: (control) -> 
            dom.register(control.get("Id"), control)
        
        _bindData: (control, id, domNode) -> 
            nodeId = id || control.get("Id")
            control.IRendererMeta._attachIds[control.get("Id")] = {} if  !control.IRendererMeta._attachIds[control.get("Id")]
            
            @_bindEvents(control, domNode, nodeId)
            @_bindAttachPoints(control, domNode, nodeId)
            
            #Actual data binding
            if control.IRendererMeta._setterBindings and not control.IRendererMeta._setterBindings._setterHandle
                control.IRendererMeta._setterBindings._setterHandle = control.watch '*', lang.hitch(this, (prop, oldvalue, value, index, self) -> 
                    if prop of control.IRendererMeta._setterBindings
                        for nodeId in control.IRendererMeta._setterBindings[prop]
                            @_draw control, nodeId, index, control.get(prop)[index] if nodeId.replace("{{_}}", index) isnt self
                    value
                )
                control.IRendererMeta._setterBindings._domHandle = lang.event.on control.domNode, 'change', this, (evt) -> 
                    domNode = evt.target or evt.srcElement
                    dataindex = domNode.getAttribute "data-index"
                    domId = domNode.id
                    domId = (domId.substring 0, domId.lastIndexOf(dataindex)) + "{{_}}" if dataindex?
                    if domId of control.IRendererMeta._dataBindings
                        dataBindings = control.IRendererMeta._dataBindings[domId]
                        for prop in dataBindings.prop
                            if not dataBindings.key? 
                                propValue = evt.target.value
                            else
                                (propValue = lang.clone(control.get(prop)[dataindex]))[dataBindings.key] = evt.target.value
                            control.set prop, propValue, dataindex, domNode.id if control.get(prop) isnt evt.target.value
                        evt.cancelBubble?()
        
        _bindEvents: (control, domNode, nodeId) -> 
            _getEvent = (eventString) -> 
                lang.trim eventString.substr(0, eventString.indexOf ":")
            _getFunction = (eventString) -> 
                func = lang.trim eventString.substr(eventString.indexOf(":") + 1)
                if func.indexOf(";") isnt -1
                    try
                        return new Function(func)
                    catch err
                        console.log(err)
                func
            attachEventDoms = dom.find '[data-attach-event]', domNode.parentNode or domNode
            for node in attachEventDoms
                events = lang.map(node.getAttribute("data-attach-event").split(","), (event) ->
                    {event: _getEvent(event), func: _getFunction(event)}
                )
                control.IRendererMeta._attachEvents[node.id] = [] if !control.IRendererMeta._attachEvents[node.id]
                for event in events
                    control.IRendererMeta._attachEvents[node.id].push lang.event.on(node, @_lookupEvent(event.event), control, event.func) if event.event and event.func
                node.removeAttribute "data-attach-event"
                control.IRendererMeta._attachIds[nodeId] = {} if  !control.IRendererMeta._attachIds[nodeId]
                control.IRendererMeta._attachIds[nodeId][node.id] = true #the attachpoints only for part of the domNode noted by nodeId
                control.IRendererMeta._attachIds[control.get("Id")][node.id] = true #all attachpoints as a dictionary keyed under the Id
            0

        _lookupEvent: (eventString) ->
            event = eventString
            switch eventString
                when "mouseenter" then event = dom.mouse.enter
                when "mouseleave" then event = dom.mouse.leave
            return event

        _bindAttachPoints: (control, domNode, nodeId) ->
            attachPointDoms = dom.find '[data-attach-point]', domNode.parentNode or domNode
            for node in attachPointDoms
                attachPointName = node.getAttribute "data-attach-point"
                control[attachPointName] = node
                control.IRendererMeta._attachPoints[node.id] = attachPointName
                node.removeAttribute "data-attach-point"
                control.IRendererMeta._attachIds[nodeId] = {} if  !control.IRendererMeta._attachIds[nodeId]
                control.IRendererMeta._attachIds[nodeId][node.id] = true #the attachpoints only for part of the domNode noted by nodeId
                control.IRendererMeta._attachIds[control.get("Id")][node.id] = true #all attachpoints as a dictionary keyed under the Id
        
        _cleanDom: (domNode) -> 
            typeAttributed = dom.find '[data-dojo-type]', domNode.parentNode or domNode
            for node in typeAttributed
                node.removeAttribute 'data-dojo-type'

        destroy: (control) ->
            control.IRendererMeta._setterBindings._setterHandle.remove() if control.IRendererMeta._setterBindings._setterHandle
            lang.event.remove control.IRendererMeta._setterBindings._domHandle if control.IRendererMeta._setterBindings._domHandle
            @_unbindData(control)
            @_removeWidgets(control)
            @_unregisterNode(control)
            dom.destroy control.get("Id")
