define [
    "dojo/_base/window"
    "dojo/_base/html"
    "dojo/dom-geometry"
    "dojo/query!css3"
    "dojo/dom-construct"
    "dojo/parser"
    "dijit/registry"
    "clazzy/Exception"
    "dojo/NodeList-traverse"
    "dijit/form/TextBox"
], (_win, _html, _domGeom, _query, _domConstruct, _parser, _registry, Exception) ->
    window.U4 = {} if not window.U4
    window.U4.__registry = {} if not window.U4.__registry
    registry = window.U4.__registry
    Dom = 
        byId: (domOrId) ->
            _html.byId(domOrId)
        destroy: (node) -> 
            _domConstruct.destroy node
        create: (html) ->
            dom = document.createElement 'div'
            dom.innerHTML = html
            dom.childNodes[0]
        find: (query, root) -> 
            _query query, root
        findAllWidgets: (rootId) -> 
            if rootId
                root = if rootId instanceof HTMLElement then rootId else @byId rootId
                if root then _registry.findWidgets root else []
        place: (node, domOrId, position) ->
            el = @byId domOrId
            switch position
                when "before" then return _domConstruct.place node, el, "before"
                when "after" then return _domConstruct.place node, el, "after"
                when "first" then return _domConstruct.place node, el, "first"
                when "last" then return _domConstruct.place node, el, "last"
                when "only" then return _domConstruct.place node, el, "only"
                when "replace" then return @replace el, node
                else _domConstruct.place node, el, "last"
        parse: (node, args) -> 
            _parser.parse(node, args)
        replace: (source, target) -> 
            _domConstruct.place target, source, "replace"
        register: (id, obj) ->
            throw new Exception("DuplicateRegistryIdException", "The object registry already has something registerd for id " + id) if registry[id]
            registry[id] = obj
        unregister: (id) -> 
            delete registry[id]
        unregisterWidget: (widgetId) -> 
            _registry.remove widgetId
