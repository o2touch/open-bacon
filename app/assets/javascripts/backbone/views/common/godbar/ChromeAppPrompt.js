BFApp.Views.ChromeAppPrompt = Marionette.ItemView.extend({

  template: "backbone/templates/common/godbar/chrome_app_prompt",
  
  className: "columns eight centered text-center",

  triggers: {
    "click button[name='add']": "add:to:chrome",
    "click .dismiss": "dismiss"
  }

});