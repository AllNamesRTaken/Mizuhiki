  define [
    "clazzy/Clazzy", 
    "clazzy/abstraction/Lang"
  ], (Class, lang, templateNameLocator, templateRegistry) -> 
    'use strict'; 
    
    Class "mizuhiki.TemplatedObject", null, null, 
      __dependencies: ["IRenderer", "IRendererMeta"]
      templateString: "<div>Dummy</div>"
      constructor: () ->
        @addModel(
          Id: null
          AttachPoint: null
        )
        @PreviousAttachPoint = null
        @PreviousId = null
        @domNode = null
        @_started = false
        @startup()
        this
      
      startup: () ->
        @_started = true
      
      render: () ->
        return @IRenderer.render(this)
      
      destroy: () ->
        return @IRenderer.destroy(this)
        
