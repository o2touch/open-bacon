App.Modelss.ActivityItemComment = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'user',
    relatedModel: 'App.Modelss.User'
  }],

  url: function() {
    return '/api/v1/activity_items/' + this.get("activity_item_id") + '/comments'
  },

  toJSON: function() {
    return {
      activity_item_comment: _.clone(this.attributes)
    }
  }

});