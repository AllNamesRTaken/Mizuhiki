define [
    "clazzy/abstraction/Lang"
    "dojo/_base/lang"
    "dojo/_base/connect"
    "dojo/on"
    "dojo/aspect"
    "clazzy/Exception"
], (_classyLang, _lang, _connect, _on, _aspect, Exception) ->
    'use strict'

    Lang = 
        clone: (obj) ->
            _lang.clone obj
        event: 
            on: (obj, event, context, method, dontFix) -> 
                _on(obj, event, Lang.hitch(context, if typeof method is "string" then context[method] else method), dontFix)
                #_connect.connect obj, event, context, method, dontFix
            remove: (handle) -> 
                handle.remove()
            emit: (target, type, eventProperties = {bubbles: true, cancelable: true}) ->
                _on.emit(target, type, eventProperties) 
        aspect: 
            after: (target, methodName, context, advice, receiveArguments = true) ->
                _aspect.after(target, methodName, Lang.hitch(context, if typeof advice is "string" then context[advice] else advice), receiveArguments)
            before: (target, methodName, context, advice) ->
                _aspect.before(target, methodName, Lang.hitch(context, if typeof advice is "string" then context[advice] else advice))
            around: (target, methodName, context, adviceFactory) ->
                _aspect.around(target, methodName, Lang.hitch(context, if typeof adviceFactory is "string" then context[advice] else adviceFactory))
            remove: (handle) -> 
                handle.remove()
        hitch: (that, func) ->
            _classyLang.hitch.apply(this, arguments)

        trim: (str) -> 
            if String::trim then str.trim() else str.replace /^\s+|\s+$/g, ""

        # Underscore abstractions

        indexOf: _classyLang.indexOf
        map: _classyLang.map

