var BFAdminApp = new Backbone.Marionette.Application();

BFAdminApp.module("Views");

// Override Marionette default template renderer
Backbone.Marionette.Renderer.render = function(template, data){
  if (!JST[template]) throw "Template '" + template + "' not found!";
  return JST[template](data);
}

BFAdminApp.addRegions({
  container: "#bfapp",
  header: "#header",
  navi: '#navi',
  content: "#content",
  footer: '#footer'
});

BFAdminApp.on('initialize:after', function(){
  //Backbone.history.start();
});