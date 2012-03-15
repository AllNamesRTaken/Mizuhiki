define [
    "clazzy/Clazzy"
], ( Class ) ->
    Class "mizuhiki.TemplatedObject", null, null, 
        templateString: "<div>Dummy</div>"
        __dependencies: ["IRenderer"],
        constructor: () -> 
            @AttachPoint = document.body
            @_attachPoints = {}
            @_attachEvents = {}
            @_attachIds = {}
            @_dataBindings = {}
            @_setterBindings = {}
            this

        render: () -> 
            @IRenderer.render this
