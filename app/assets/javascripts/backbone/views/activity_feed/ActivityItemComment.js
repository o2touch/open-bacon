BFApp.Views.ActivityItemComment = Marionette.ItemView.extend({

  tagName: "li",

  className: "comment clearfix",

  template: "backbone/templates/activity_feed/activity_item_comment_row",

  serializeData: function() {
    return {
      user: this.model.get("user"),
      text: this.model.get("text"),
      date: moment(this.model.get("created_at")).fromNow()
    };
  },

  onRender: function() {
    var msgParagraph = this.$el.find(".actual-comment-text");
    var html = msgParagraph.html();
    html = addLinkTags(html);
    msgParagraph.html(html);
  }

});