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
