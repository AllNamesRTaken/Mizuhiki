Mizuhiki - data binding with Clazz
----------------------------------
Mizuhiki is a module that:

- takes a templated class
- reads its template
- parses it through mustache (with one small change to handle binding to arrays)
- renders it using dojo
- binds the dom to the class properties, through setters and getters
- hooks up dojo specifics such as attachpoint and attachevent
- partially re-render the needed html when given properties change

No coding needed to bind; all done in the template.

Just create a templated object and a template (look at the tests for ideas) and call Mizuhiki.render.

A valid template could look like this (taken from tests):

```html
<div>
    <input type="text" value="{{Text}}" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="{{Id}}_input" data-bind-to="Text" />
    <label for="{{Id}}_input">
        <span id="{{Id}}_LastUpdated" data-bind-to="Text">{{Text}}</span> 
    </label>
    <br />
    {{#DataArray}}
        <input type="text" value="{{data}}" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="{{Id}}arrText{{_}}" data-bind-to="DataArray" data-bind-to-key="data" data-index={{_}} />
        <label for="{{Id}}arrText{{_}}">
            <span id="{{Id}}arrSpan{{_}}" data-bind-to="DataArray" data-index={{_}}>{{data}}</span> 
        </label>
        <br />
    {{/DataArray}}
    {{^notSet}}
        notSet wasnt set
    {{/notSet}}
    <br />
    {{! ignore me }} was ignored
    <br />
    {{#objectContext}}
        {{objectValue}}
    {{/objectContext}}
    <br />
    Changing tags
    {{=<< >>=}}
    <<#shoutIt>>
        bazinga
    <</shoutIt>>
</div>
```

in the tests I have a partial in the template, but that is only supported by SoyaMilk (the mustache port) and not yet by Mizuhiki.

Also the **Id** property of the control will, if not set, be set automatically when the control is rendered and the top element in the template will get its id set to this Id.

and an object and the use of Mizuhiki could look like:

```coffeescript
require [
    "clazzy/Clazzy"
    "mizuhiki/Mizuhiki"
    "mizuhiki/TemplatedObject"
    "dojo/text!some/path/Template.html"
], (Class, Mizuhiki, TemplatedObject, Template) ->
    Class "some.namespace.MyClass", TemplatedObject, null,
        Text: "someText"
        templateString: Template
        constructor: ()->
            @DataArray = [{data:"data1"},{data:"data2"}]
            @objectContext = 
                objectValue: "somevalue"
            this
        shoutIt: ()->
            (text)->
                text.toUpperCase

    # meanwhile somewhere else

    window.myRenderer = new Mizuhiki()

    myobject = new some.namespace.MyClass({
        Text:"someOtherText"
        IRenderer: window.myRenderer
    })
    myobject.render()
```
Ofcourse in a project you would register Mizuhiki as the choice for IRenderer in the Registrar and let the IoC of Clazzy inject that for you.
