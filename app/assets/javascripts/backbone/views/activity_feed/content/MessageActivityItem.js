BFApp.Views.MessageActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/message_created",

  initialize: function(options) {
    this.context = options.context;
  },

  serializeData: function() {
    var data = {
      user: this.model.get("subj"),
      messageable: false,
      league: false,
      text: this.model.get("obj").get("text")
    };
    // if there is a "messageable" object, then use it to create a proper model instance
    var obj = this.model.get("obj");
    if (obj.get("messageable_id")) {
      var messageable;
      var type = obj.getType();
      if (type == "event") {
        messageable = App.Modelss.Event.findOrCreate(obj.get("messageable"));
      } else if (type == "team") {
        messageable = App.Modelss.Team.findOrCreate(obj.get("messageable"));
      } else if (type == "division") {
        data.league = App.Modelss.League.findOrCreate(obj.get("messageable").league);
      }

      // if current page is not same type as where the message was created...
      if (messageable && this.context != type) {
        data.messageable = messageable;
      }
    }

    return data;
  },

  onRender: function() {
    var msgParagraph = this.$el.find(".message-content p");
    var html = msgParagraph.html();
    html = addLinkTags(html);
    html = html.replace(/\r?\n/g, '<br>');
    msgParagraph.html(html);
  }

});