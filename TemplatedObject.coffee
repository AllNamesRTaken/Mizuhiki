define [
    "clazzy/Clazzy"
], ( Class ) ->
    Class "mizuhiki.TemplatedObject", null, null, 
        templateString: "<div>Dummy</div>"
        __dependencies: ["IRenderer"],
        constructor: () -> 
            @AttachPoint = null
            @PreviousAttachPoint = null
            @Id = null
            @PreviousId = null
            @domNode = null
            @_attachPoints = {}
            @_attachEvents = {}
            @_attachIds = {}
            @_dataBindings = {}
            @_setterBindings = {}
            @_started = false
            @startup()
            this
        
        startup: () ->
            @_started = true

        render: () -> 
            @IRenderer.render this

        destroy: () -> 
            @IRenderer.destroy this
