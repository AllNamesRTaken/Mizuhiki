// Generated by CoffeeScript 1.8.0
(function() {
  define(["dojo/main", "util/doh/main", "mizuhiki/SoyaMilk", "dojo/cache", "dojo/_base/url"], function(dojo, doh, soyamilk, cache, _url) {
    return doh.register("mizuhiki.tests.SoyaMilk", [
      {
        name: "render_complexTemplateWithData_generatesCorrectHtml ->",
        setUp: function() {
          var partialUrl, templateUrl;
          templateUrl = "../../mizuhiki/tests/resources/Template.html";
          this.templateString = cache(new _url(templateUrl));
          partialUrl = "../../mizuhiki/tests/resources/Partial.html";
          this.partialString = cache(new _url(partialUrl));
          this.data = {
            Id: "someid",
            Text: "sometext",
            DataArray: [
              {
                data: "somedata"
              }, {
                data: "somedata"
              }
            ],
            objectContext: {
              objectValue: "somevalue"
            },
            shoutIt: function() {
              return function(text) {
                return text.toUpperCase();
              };
            }
          };
          return this.expectedHtml = '<div id="someid"> <input type="text" value="sometext" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="someid_input" data-bind-to="Text" /> <label for="someid_input"> <span id="someid_LastUpdated" data-bind-to="Text">sometext</span> </label> <br /> <input type="text" value="somedata" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="someidarrText0" data-bind-to="DataArray" data-bind-to-key="data" data-index=0 /> <label for="someidarrText0"> <span id="someidarrSpan0" data-bind-to="DataArray" data-index=0>somedata</span> </label>        <br /> <input type="text" value="somedata" data-dojo-type="dijit.form.TextBox" data-dojo-props="trim:true, propercase:true" id="someidarrText1" data-bind-to="DataArray" data-bind-to-key="data" data-index=1 /> <label for="someidarrText1"> <span id="someidarrSpan1" data-bind-to="DataArray" data-index=1>somedata</span> </label>        <br /> notSet wasnt set <br /> was ignored <br /> somevalue <br /> Changing tags BAZINGA</div>'.replace(/[\r\n]/g, "").replace(/[ ]+/g, " ");
        },
        runTest: function(t) {
          var html;
          html = soyamilk.render(this.templateString, this.data, {
            myPartial: this.partialString
          });
          html = html.replace(/[\r\n]/g, "").replace(/[ ]+/g, " ");
          return doh.assertEqual(this.expectedHtml, html);
        }
      }
    ]);
  });

}).call(this);

//# sourceMappingURL=SoyaMilk.js.map
