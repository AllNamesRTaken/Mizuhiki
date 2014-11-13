define [
    "clazzy/Clazzy"
], ( Class) ->
    'use strict'

    Class "mizuhiki.MizuhikiMeta", null, null, 
        constructor: () -> 
            @_attachPoints = {}
            @_attachEvents = {}
            @_attachIds = {}
            @_dataBindings = {}
            @_setterBindings = {}

            this
