define [
	"dojo/main" 
	"util/doh/main" 
	"mizuhiki/SoyaMilk"
    "dojo/cache"
    "dojo/_base/url"
], (dojo, doh, soyamilk, cache, _url) ->

    #this is really not a unit test, but makes sure 
    #that the soyamilk renderer renderers a complex
    #template correctly
    #Error handling and error messages not tested

    doh.register "mizuhiki.tests.SoyaMilk", [

        name: "render_complexTemplateWithData_generatesCorrectHtml ->"
        setUp: () ->
            #Arrange
            templateUrl = "../../../mizuhiki/tests/resources/Template.html"
            @templateString = cache new _url(templateUrl)
            partialUrl = "../../../mizuhiki/tests/resources/Partial.html"
            @partialString = cache new _url(partialUrl)
            @data = 
                Id: "someid"
                Text: "sometext"
                DataArray: [{data: "somedata"},{data: "somedata"}]
                objectContext: 
                    objectValue: "somevalue"
                shoutIt: () -> 
                    (text) ->
                        text.toUpperCase()
            @expectedHtml = '<div id="someid">
                <input type="text" value="sometext" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="someid_input" data-bind-to="Text" />
                <label for="someid_input">
                <span id="someid_LastUpdated" data-bind-to="Text">sometext</span> 
                </label>
                <br />
                <input type="text" value="somedata" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="someidarrText0" data-bind-to="DataArray" data-bind-to-key="data" data-index=0 />
                <label for="someidarrText0">
                <span id="someidarrSpan0" data-bind-to="DataArray" data-index=0>somedata</span> 
                </label>        <br />
                <input type="text" value="somedata" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="someidarrText1" data-bind-to="DataArray" data-bind-to-key="data" data-index=1 />
                <label for="someidarrText1">
                <span id="someidarrSpan1" data-bind-to="DataArray" data-index=1>somedata</span> 
                </label>        <br />
                notSet wasnt set <br />
                was ignored <br />
                somevalue <br />
                Changing tags BAZINGA</div>'.replace(/[\r\n]/g, "").replace(/[ ]+/g, " ")
        runTest: (t) -> 
            #Act
            html = soyamilk.render(@templateString, @data, {myPartial: @partialString})
            html = html.replace(/[\r\n]/g, "").replace(/[ ]+/g, " ")
            #Assert
            doh.assertEqual @expectedHtml, html
    ]
