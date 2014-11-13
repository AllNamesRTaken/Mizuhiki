define [
    "dojo/main"
    "util/doh/main"
    "mizuhiki/TemplatedObject"
], (dojo, doh, TemplatedObject) ->

    doh.register "mizuhiki.tests.TemplatedObject", [

        name: "new_Class_propertiesCreated"
        setUp: () ->
            #Arrange
        runTest: (t) -> 
            #Act
            obj = new TemplatedObject()
            #Assert
            doh.assertTrue obj.haz "AttachPoint"
            doh.assertTrue obj.haz "PreviousAttachPoint"
            doh.assertTrue obj.haz "PreviousId"
            doh.assertTrue obj.haz "domNode"
            doh.assertTrue obj.haz "_started"
    ,
        name: "render_null_callsIRendererRender"
        setUp: () ->
            #Arrange
            @obj = new TemplatedObject()
        runTest: (t) -> 
            IRendererCalled = false
            @obj.IRenderer = 
                render: (obj) ->
                    IRendererCalled = true
            #Act
            @obj.render()
            #Assert
            doh.assertTrue IRendererCalled
    ,
        name: "destroy_null_callsIRendererDestroy"
        setUp: () ->
            #Arrange
            @obj = new TemplatedObject()
        runTest: (t) -> 
            IRendererCalled = false
            @obj.IRenderer = 
                destroy: (obj) ->
                    IRendererCalled = true
            #Act
            @obj.destroy()
            #Assert
            doh.assertTrue IRendererCalled
    ]
