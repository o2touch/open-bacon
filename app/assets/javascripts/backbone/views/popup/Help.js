BFApp.Views.HelpPopup = Marionette.Layout.extend({

  template: "backbone/templates/popups/help",

  regions: {
    content: "#help-popup-content"
  },

  triggers: {
    "click a.x": "close:popup"
  },

  events: {
    'click a[name=chat]': 'clickedChat'
  },

  initialize: function() {
    analytics.track('Viewed Help - Index', {});
  },

  serializeData: function() {
    return {
      feedbackUrl: ActiveApp.Tenant.get("page_options").feedback_url,
      supportUrl: ActiveApp.Tenant.get("page_options").support_url
    };
  },

  clickedChat: function(e) {
    e.preventDefault();
    // Answer Connect's shitty globals
    $conversion.startChat();
  }

});