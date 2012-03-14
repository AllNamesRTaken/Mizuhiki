define [
    "dojo/main" 
    "util/doh/main" 
    "mizuhiki/abstraction/Lang" 
    "clazzy/Exception"
], (dojo, doh, lang, Exception) ->

    doh.register "clazzy.tests.abstraction.Lang", [
        name: "clone_objectWithObjectWithArrayInsideArray_areEqual"
        setUp: () ->
            #Arrange
            @testObject = {a:{b:[[true,true],[false,false]]}}
        runTest: (t) -> 
            #Act
            clone = lang.clone @testObject
            #Assert
            doh.assertEqual @testObject, clone
    ,
        name: "eventOn_eventToFunction_functionIsCalledOnEvent"
        setUp: () ->
            #Arrange
            @node = document.createElement "div"
        runTest: (t) ->
            wasCalled = false
            @func1 = () -> wasCalled = true
            lang.event.on @node, "click", this, "func1"
            #Act
            lang.event.emit @node, "click"
            #Assert
            doh.assertTrue wasCalled
    ,
        name: "eventRemove_eventToFunction_functionIsNotCalledOnEvent"
        setUp: () ->
            #Arrange
            @node = document.createElement "div"
        runTest: (t) ->
            wasCalled = false
            @func1 = () -> wasCalled = true
            handle = lang.event.on @node, "click", this, "func1"
            lang.event.remove handle
            #Act
            lang.event.emit @node, "click"
            #Assert
            doh.assertFalse wasCalled
    ,
        name: "aspectBefore_functionToFunction_secondFunctionIsCalledWithSameArguments"
        setUp: () ->
            #Arrange
        runTest: (t) ->
            wasCalled = ""
            a1 = true
            a2 = false
            @func1 = (arg1, arg2) -> wasCalled = wasCalled + "func1"
            @func2 = (arg1, arg2) -> 
                wasCalled = wasCalled + (if arg1 is a1 and arg2 is a2 then "func2" else "")
                [arg1, arg2] #return the parameters for func1
            lang.aspect.before this, "func1", this, @func2
            #Act
            @func1 a1, a2
            #Assert
            doh.assertEqual "func2func1", wasCalled
    ,
        name: "aspectAround_functionToFunction_secondFunctionIsCalledWithSameArguments"
        setUp: () ->
            #Arrange
        runTest: (t) ->
            wasCalled = ""
            a1 = true
            a2 = false
            @func1 = (arg1, arg2) -> wasCalled = wasCalled + "func1"
            @func2 = (originalFunc) -> 
                (arg1, arg2) -> 
                    wasCalled = wasCalled + (if arg1 is a1 and arg2 is a2 then "func2" else "")
                    originalFunc(arg1, arg2)
                    wasCalled = wasCalled + (if arg1 is a1 and arg2 is a2 then "func2" else "")
                
            lang.aspect.around this, "func1", this, @func2
            #Act
            @func1 a1, a2
            #Assert
            doh.assertEqual "func2func1func2", wasCalled
    ,
        name: "aspectAfter_functionToFunction_secondFunctionIsCalledWithSameArguments"
        setUp: () ->
            #Arrange
        runTest: (t) ->
            wasCalled = ""
            a1 = true
            a2 = false
            @func1 = (arg1, arg2) -> wasCalled = wasCalled + "func1"
            @func2 = (arg1, arg2) -> 
                wasCalled = wasCalled + (if arg1 is a1 and arg2 is a2 then "func2" else "")
            lang.aspect.after this, "func1", this, @func2
            #Act
            @func1 a1, a2
            #Assert
            doh.assertEqual "func1func2", wasCalled
    ,
        name: "aspectRemove_handle_secondFunctionIsNotCalled"
        setUp: () ->
            #Arrange
            @wasCalled = false
            @a1 = true
            @a2 = false
            @func1 = (arg1, arg2) -> null
            @func2 = (arg1, arg2) -> 
                console.log "func2"
                @wasCalled = arg1 is @a1 and arg2 is @a2
            @handle = lang.aspect.after this, "func1", this, this.func2
        runTest: (t) ->
            #Act
            lang.aspect.remove @handle
            @func1 @a1, @a2
            #Assert
            doh.assertFalse @wasCalled
    ,
        name: "hitch_contextAndFunction_hitchedFunctionRunsSetContext"
        setUp: () ->
            #Arrange
            @context = {}
            @hitch = lang.hitch @context, () -> return this
        runTest: (t) ->
            #Act
            context = @hitch()
            #Assert
            doh.assertEqual @context, context
    ,
        name: "hitch_nullContextAndFunction_hitchedFunctionRunsThisContext"
        setUp: () ->
            #Arrange
            @context = null
            @hitch = lang.hitch @context, () -> return this
        runTest: (t) ->
            #Act
            context = @hitch()
            #Assert
            doh.assertEqual this, context
    ,
        name: "trim_undefined_ThrowsTypeError"
        setUp: () ->
            #Arrange
            @string = undefined
        runTest: (t) ->
            #Act
            #Assert
            doh.assertError TypeError, lang, "trim", [@string]
    ,
        name: "trim_null_ThrowsTypeError"
        setUp: () ->
            #Arrange
            @string = null
        runTest: (t) ->
            #Act
            #Assert
            doh.assertError TypeError, lang, "trim", [@string]
    ,
        name: "trim_stringWithSpacesAroundAndInside_stringWithoutSpacesAround"
        setUp: () ->
            #Arrange
            @stringWithSpaces = " text here "
        runTest: (t) ->
            #Act
            trimmedString = lang.trim @stringWithSpaces
            #Assert
            doh.assertEqual "text here", trimmedString

    ]
