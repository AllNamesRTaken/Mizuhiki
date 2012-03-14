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
            doh.assertEqual {}, obj._attachPoints
            doh.assertEqual {}, obj._attachEvents
            doh.assertEqual {}, obj._attachIds
            doh.assertEqual {}, obj._dataBindings
            doh.assertEqual {}, obj._setterBindings
    ,
        name: "render_null_callsIRenderer"
        setUp: () ->
            #Arrange
            @obj = new TemplatedObject()
        runTest: (t) -> 
            IRendererCalled = false
            @obj.IRenderer = 
                render: (obj) ->
            IRendererCalled = true
            #Act
            #Assert
            doh.assertTrue IRendererCalled
    ]
