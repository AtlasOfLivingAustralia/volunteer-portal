//= encoding UTF-8
//  assume jquery
//= require compile/mustache/2.0.0/mustache.js
//= require_self
var mu = {};
(function(mlib) {
  var templates = {};
  jQuery(function($) {

    $('script[type="x-tmpl-mustache"], script[type="text/x-mustache-template"]').each(function () {
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
})(mu);