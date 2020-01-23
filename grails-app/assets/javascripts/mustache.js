//= encoding UTF-8
//  assume jquery
//= require compile/mustache/2.0.0/mustache.js
//= require compile/set-dom/7.5.2/set-dom.js
//= require_self
var mu = {};
(function(mlib) {
  var templates = {};
  jQuery(function($) {
    // also find handlerbars type because intellij highlighting doesn't care for mustache type scripts
    $('script[type="x-tmpl-mustache"], script[type="text/x-mustache-template"], script[type="text/x-handlebars"]').each(function () {
      var $this = $(this);
      var content = $this.html();
      templates[$this.prop('id')] = content;
      Mustache.parse(content);
    });
  });

  mlib.appendTemplate = function (parent, template, opts) {
    var rendered = Mustache.render(templates[template], opts);
    var $rendered = $(rendered);
    $rendered.appendTo(parent);
    return $rendered;
  };

  mlib.replaceTemplate = function(parent, template, opts) {
    var rendered = Mustache.render(templates[template], opts);
    var $rendered = $(rendered);
    parent.empty();
    $rendered.appendTo(parent);
    return $rendered;
  };
  /**
   * Update a node using a dom diffing algorithm instead of clearing the content and rendering it new.  This allows
   * animations and the like to continue running instead of starting over.
   *
   * When using this method, the template should render the parent container as well, unlike the replaceTemplate and
   * appendTemplate methods.
   *
   * @param updateNode The DOM node (not jquery) to update
   * @param template The template to use to update the node
   * @param opts The data for the template
   */
  mlib.updateTemplate = function(updateNode, template, opts) {
    var rendered = Mustache.render(templates[template], opts);
    if (!rendered) console.log("template " + template + " rendered is null");
    setDOM(updateNode, rendered);
  }
})(mu);