App.Modelss.ActivityItemLike = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'user',
    relatedModel: 'App.Modelss.User'
  }],

  initialize: function() {

  },

  url: function() {
    return '/api/v1/activity_items/' + this.get("activity_item_id") + '/likes'
  },

  toJSON: function() {
    return {
      activity_item_like: _.clone(this.attributes)
    }
  }

});