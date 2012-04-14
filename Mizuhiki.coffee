define [
    "clazzy/Clazzy"
    "mizuhiki/abstraction/Lang" #used for event (on),trim,clone
    "mizuhiki/abstraction/Dom" #used for byId,findAllWidgets,unregister,unregisterWidget,create,find,parse,place,register,destroy
    "mizuhiki/SoyaMilk" #Mustache in Coffeescript -> Milk, Milk + AMD + MVVM fairy dust -> SoyaMilk
    "clazzy/Exception"
    "mizuhiki/TemplatedObject"
], ( Class, _lang, _dom, soyamilk, Exception, TemplatedObject) ->
    'use strict'

    Class "mizuhiki.Mizuhiki", null, null, 

        render: (control) -> 
            @_draw control
        
        # Private Functions
        _draw: (control, id, index, data) -> 
            throw new Exception("IllegalObjectException", "Control isnt of type TemplatedObject") if control?.isnt TemplatedObject
            control.Id or= @generateGuid()
            console.warn("No AttachPoint set on control " + control.Id + ". Control wont be visible.") if not control.AttachPoint
            nodeId = id.replace "{{_}}", index if id
            @_unbindData control, nodeId
            @_removeWidgets control, nodeId    #Dojo specifics, destroyRecursive
            @_unregisterNode control if not id
            @_calculateBindings control if not control._dataBindings.parsed
            html = @_parseTemplate control, id, index, data
            html = @__frameworkReplaceCustomAttributes html    #Dojo specifics 
            node = @_placeHtml control, html, nodeId
            node.id = control.Id if not id
            @_registerNode control if not id
            @__frameworkParse node
            @_runGenerators control, node
            @_bindData control, nodeId, node if control.AttachPoint
            @_cleanDom node
            control.PreviousId = control.Id
            control.PreviousAttachPoint = control.AttachPoint

        generateGuid: (withDash = false, checkForNodes = true) ->
            d = if withDash then "-" else ""
            S4 = () ->
                (((1+Math.random())*0x10000)|0).toString(16).substring(1)
            guid = (S4()+S4()+d+S4()+d+S4()+d+S4()+d+S4()+S4()+S4())
            while checkForNodes and _dom.byId(guid)
                guid = (S4()+S4()+d+S4()+d+S4()+d+S4()+d+S4()+S4()+S4())
            guid

        _unbindData: (control, id) -> 
            nodeId = id or control.PreviousId or control.Id
            return if not nodeId
            node = _dom.byId nodeId
            return if not node
            #Only proceed if the control has a rendered UI
            if not id
                #If _drawing the entire control and not a subsection disconnect connection for setters as well as for the onchange on the dom
                control._setterBindings._setterHandle.remove() if control._setterBindings._setterHandle
                _lang.event.remove control._setterBindings._domHandle if control._setterBindings._domHandle
            for key of control._attachIds[nodeId]
                #disconnect all events attached through the template and remove all pointers to attachpoints and events
                _lang.event.remove(handle) for handle in control._attachEvents[key] if key of control._attachEvents
                delete control[control._attachPoints[key]] if control._attachPoints[key]
                delete control._attachPoints[key] if control._attachPoints[key]
                delete control._attachEvents[key] if control._attachEvents[key]
                delete control._attachIds[control.PreviousId || control.Id][key]
            delete control._attachIds[nodeId]

        _removeWidgets: (control, id) -> 
            nodeId = id or control.PreviousId or control.Id
            return if not nodeId
            node.destroyRecursive() for node in _dom.findAllWidgets(nodeId)
            _dom.unregisterWidget(nodeId)

        _unregisterNode: (control) -> 
            _dom.unregister(control.PreviousId or control.Id)
        
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
            templateDom = _dom.create control.templateString
            databound = _dom.find '[data-bind-to]', templateDom
            if databound.length > 0
                for i in [0..databound.length-1]
                    itemId = databound[i].id.replace "{{_}}", "_____"
                    itemId = _lang.trim(soyamilk.render(itemId, control, control.partials or= {})).replace "_____", "{{_}}"
                    control._dataBindings[itemId] = 
                        html: outerHTML(databound[i])
                        prop: databound[i].getAttribute('data-bind-to').split(',').map (el) ->
                            el.trim()
                        key: databound[i].getAttribute('data-bind-to-key')
                    for prop in control._dataBindings[itemId].prop
                        control._setterBindings[prop] = [] if not control._setterBindings[prop]
                        control._setterBindings[prop].push itemId
            control._dataBindings.parsed = true
        
        _parseTemplate: (control, id, index, data) -> 
            if !id?
                return _lang.trim(soyamilk.render(control.templateString, control, control.partials or= {}))
            templateString = if index? then control._dataBindings[id].html.replace(/{{_}}/g, index) else control._dataBindings[id].html
            if index
                for key, value of data
                    regex = new RegExp "{{"+key+"}}"
                    templateString = templateString.replace(regex, value)
            _lang.trim(soyamilk.render(templateString, control, control.partials or= {}))

        __frameworkReplaceCustomAttributes: (html) -> 
            html = html.replace(/data-dojo-attach/gi, "data-cleaned-attach");

        __frameworkParse: (dom) -> 
            if dom.parentNode and dom.hasAttribute "data-dojo-type"
                _dom.parse(dom.parentNode)
            else
                _dom.parse(dom)
        _runGenerators: (control, node) ->
            for generatorNode in _dom.find "[data-generator-function]", node
                if (f = control[generatorNode.getAttribute("data-generator-function")]).call?
                    _dom.replace generatorNode, f()

        _placeHtml: (control, html, id) -> 
            nodeId = id or control.PreviousId
            dom = _dom.create(html)
            widgetId = "widget_" + id if _dom.byId("widget_" + id)
            idPassed = nodeId is id
            attachPoint = if "string" is typeof control.AttachPoint then (if control.AttachPoint is "body" then document.body else _dom.byId(control.AttachPoint)) else control.AttachPoint
            prevAttachPoint = control.PreviousAttachPoint

            removeDom = (not attachPoint? and prevAttachPoint?) or (attachPoint? and prevAttachPoint? and attachPoint isnt prevAttachPoint)
            replaceDom = prevAttachPoint? and attachPoint is prevAttachPoint
            placeNewDom = attachPoint? and not replaceDom
            
            if removeDom
                _dom.destroy control.Id
            if replaceDom
                _dom.place(dom, (if idPassed then widgetId or nodeId else control.PreviousId), 'replace')
            if placeNewDom
                _dom.place(dom, attachPoint)
            if not id
                control.domNode = dom
            dom

        _registerNode: (control) -> 
            _dom.register(control.Id, control)
        
        _bindData: (control, id, dom) -> 
            nodeId = id || control.Id
            control._attachIds[control.Id] = {} if  !control._attachIds[control.Id]
            
            @_bindEvents(control, dom, nodeId)
            @_bindAttachPoints(control, dom, nodeId)
            
            #Actual data binding
            if control._setterBindings and not control._setterBindings._setterHandle
                control._setterBindings._setterHandle = control.watch '*', _lang.hitch(this, (prop, oldvalue, value, index, self) -> 
                    if prop of control._setterBindings
                        for nodeId in control._setterBindings[prop]
                            @_draw control, nodeId, index, control[prop][index] if nodeId.replace("{{_}}", index) isnt self
                    value
                )
                control._setterBindings._domHandle = _lang.event.on _dom.byId(control.Id), 'change', this, (evt) -> 
                    dom = evt.target or evt.srcElement
                    dataindex = dom.getAttribute "data-index"
                    domId = dom.id
                    domId = (domId.substring 0, domId.lastIndexOf(dataindex)) + "{{_}}" if dataindex?
                    if domId of control._dataBindings
                        dataBindings = control._dataBindings[domId]
                        for prop in dataBindings.prop
                            if not dataBindings.key? 
                                propValue = evt.target.value
                            else
                                (propValue = _lang.clone(control.get(prop)[dataindex]))[dataBindings.key] = evt.target.value
                            control.set prop, propValue, dataindex, dom.id if control[prop] isnt evt.target.value
                        evt.cancelBubble?()
        
        _bindEvents: (control, dom, nodeId) -> 
            _getEvent = (eventString) -> 
                _lang.trim eventString.substr(0, eventString.indexOf ":")
            _getFunction = (eventString) -> 
                _lang.trim eventString.substr(eventString.indexOf(":") + 1)

            attachEventDoms = _dom.find '[data-cleaned-attach-event]', dom
            for node in attachEventDoms
                events = (node.getAttribute "data-cleaned-attach-event").split(",").map (event) ->
                    {event: _getEvent(event), func: _getFunction(event)}
                
                control._attachEvents[node.id] = [] if !control._attachEvents[node.id]
                for event in events
                    control._attachEvents[node.id].push _lang.event.on(node, event.event, control, event.func) if event.event and event.func
                node.removeAttribute "data-cleaned-attach-event"
                control._attachIds[nodeId] = {} if  !control._attachIds[nodeId]
                control._attachIds[nodeId][node.id] = true #the attachpoints only for part of the dom noted by nodeId
                control._attachIds[control.Id][node.id] = true #all attachpoints as a dictionary keyed under the Id
            0

        _bindAttachPoints: (control, dom, nodeId) ->
            attachPointDoms = _dom.find '[data-cleaned-attach-point]', dom
            for node in attachPointDoms
                attachPointName = node.getAttribute "data-cleaned-attach-point"
                control[attachPointName] = node
                control._attachPoints[node.id] = attachPointName
                node.removeAttribute "data-cleaned-attach-point"
                control._attachIds[nodeId] = {} if  !control._attachIds[nodeId]
                control._attachIds[nodeId][node.id] = true #the attachpoints only for part of the dom noted by nodeId
                control._attachIds[control.Id][node.id] = true #all attachpoints as a dictionary keyed under the Id
        
        _cleanDom: (dom) -> 
            typeAttributed = _dom.find '[data-dojo-type]', dom
            for node in typeAttributed
                node.removeAttribute 'data-dojo-type'

        destroy: (control) ->
            control._setterBindings._setterHandle.remove() if control._setterBindings._setterHandle
            _lang.event.remove control._setterBindings._domHandle if control._setterBindings._domHandle
            @_unbindData(control)
            @_removeWidgets(control)
            @_unregisterNode(control)
            _dom.destroy control.Id
