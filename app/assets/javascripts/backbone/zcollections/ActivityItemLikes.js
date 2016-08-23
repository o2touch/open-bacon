App.Collections.ActivityItemLikes = Backbone.Collection.extend({

  model: App.Modelss.ActivityItemLike,

  // sorting likes: put you first, then the others in the order they were created
  comparator: function(model) {
    if (model.get("user").isCurrentUser()) {
      return 1;
    } else {
      return moment(model.get("created_at")).valueOf();
    }
  },

  isLikedByCurrentUser: function() {
    return (this.length && this.at(0).get("user").isCurrentUser());
  },

  getLikeForCurrentUser: function() {
    if (this.length) {
      var like = this.at(0);
      return (like.get("user").isCurrentUser()) ? like : null;
    } else {
      return null;
    }
  }

});