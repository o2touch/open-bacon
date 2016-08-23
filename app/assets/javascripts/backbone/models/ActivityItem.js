App.Modelss.ActivityItem = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasMany,
    key: 'likes',
    relatedModel: 'App.Modelss.ActivityItemLike',
    collectionType: 'App.Collections.ActivityItemLikes'
  }, {
    type: Backbone.HasMany,
    key: 'comments',
    relatedModel: 'App.Modelss.ActivityItemComment',
    collectionType: 'App.Collections.ActivityItemComments'
  }, {
    type: Backbone.HasOne,
    key: 'subj',
    relatedModel: 'App.Modelss.User'
  }, {
    type: Backbone.HasOne,
    key: 'obj',
    relatedModel: 'App.Modelss.ActivityItemObject'
  }],

  likeableItems: [
    "EVENTCREATED",
    "MESSAGECREATED",
    "EVENTUPDATED",
    "EVENTCANCELLED",
    "EVENTACTIVATED",
    "EVENTCREATED",
    "EVENTRESULTUPDATED",
    "INVITERESPONSECREATED"
  ],

  commentableItems: [
    "EVENTCREATED",
    "MESSAGECREATED",
    "EVENTUPDATED",
    "EVENTCANCELLED",
    "EVENTACTIVATED",
    "EVENTCREATED",
    "EVENTRESULTUPDATED",
    "INVITERESPONSECREATED"
  ],

  // this is required for the tests, so we can call model.destroy() without it moaning
  url: "/api/v1/activity_items",

  initialize: function() {

    // Protect ourselves against deleted obj
    if (this.get("obj") == null) {
      return;
    }

    // if it's a message, check if the context is right
    // (we didn't have access to this in the parse function)
    if (this.get("obj").get("obj_type") == "EventMessage") {
      var type = this.get("obj").getType();
      if (this.collection && type != this.collection.context) {
        this.set("starred_at", false);
      }
    }
  },

  parse: function(response, xhr) {

    // Protect ourselves against deleted obj
    if (response.obj == null) {
      return response;
    }

    // FE now needs this type field to be inside the object, but SR says the BE
    // needs it to be outside, so fix it here
    if (response.obj) {
      response.obj.obj_type = response.obj_type;
    }

    // set convenience attribute: starred_at
    if (response.obj.obj_type == "EventMessage" && response.meta_data) {
      // JACK TODO - remove this line when BE pass JSON instead of a string
      var metaData = JSON.parse(response.meta_data);
      response.starred_at = (metaData.starred_at) ? metaData.starred_at : false;
    }

    return response;
  },

  isStarred: function() {
    return (this.get("starred_at"));
  },


  deleteLike: function(user, callback) {
    var params = {
      activity_item_id: this.get("id"),
      user_id: user.get("id")
    };
    var model = this.get("likes").where(params)[0];
    model.destroy({
      error: function() {
        errorHandler();
        if (typeof(callback) == "function") callback();
      }
    });
    this.get("likes").remove(model);
  },

  createLike: function(user) {
    var like = new App.Modelss.ActivityItemLike();
    like.save({
      activity_item_id: this.get("id")
    }, {
      error: function() {
        errorHandler();
      }
    });
    like.set({
      user: user
    });
    this.get("likes").add(like);
  },


  setStarred: function(star) {
    // set starred_at time to now to put it at top of list
    var starredAt = (star) ? moment().toCustomISO() : false;
    this.set("starred_at", starredAt);

    // tell the BE
    this.toJSON = function() {
      // JO 11/07/13 - normal practice is to wrap data in parent object, with key
      // set to classname e.g. {activity_item: data} but it is working as it is ATM
      // and TS says the BE code for this stuff is ugly and will take too long to
      // change, so leave it for now
      return {
        meta_data: {
          starred: star
        }
      };
    };
    this.save({}, {
      url: "/api/v1/activity_items/" + this.get("id"),
      error: function() {
        errorHandler();
      }
    });
  },

  likeable: function() {
    return (this.likeableItems.indexOf(this.getActivityItemType()) != -1);
  },

  commentable: function() {
    return (this.commentableItems.indexOf(this.getActivityItemType()) != -1);
  },

  likedByUser: function(user) {
    return _.any(this.get("likes").models, function(like) {
      return like.get("user").get("id") == user.get("id");
    });
  },

  getActivityItemType: function() {
    var item_type;
    if (this.get("obj_type") == "Event" && this.get("verb") == "created") {
      item_type = "EVENTCREATED";
    } else if (this.get("obj_type") == "TeamsheetEntry" && (this.get("verb") == "added_to" || this.get("verb") == "created")) {
      item_type = "TEAMSHEETENTRYADDEDTO";
    } else if (this.get("obj_type") == "EventMessage" && this.get("verb") == "created") {
      item_type = "MESSAGECREATED";
    } else if (this.get("obj_type") == "InviteResponse" && this.get("verb") == "created") {
      item_type = "INVITERESPONSECREATED";
    } else if (this.get("obj_type") == "InviteReminder" && this.get("verb") == "sent") {
      item_type = "INVITEREMINDERSENT";
    } else if (this.get("obj_type") == "InviteReminder" && this.get("verb") == "created") {
      item_type = "INVITEREMINDERSENT";
    } else if (this.get("obj_type") == "Event" && this.get("verb") == "updated") {
      item_type = "EVENTUPDATED";
    } else if (this.get("obj_type") == "Event" && this.get("verb") == "cancelled") {
      item_type = "EVENTCANCELLED";
    } else if (this.get("obj_type") == "Event" && this.get("verb") == "activated") {
      item_type = "EVENTACTIVATED";
    } else if (this.get("obj_type") == "Event" && this.get("verb") == "postponed") {
      item_type = "EVENTPOSTPONED";
    } else if (this.get("obj_type") == "Event" && this.get("verb") == "rescheduled") {
      item_type = "EVENTRESCHEDULED";
    } else if (this.get("obj_type") == "EventResult" && this.get("verb") == "updated") {
      item_type = "EVENTRESULTUPDATED";
    }
    return item_type;
  },

  /*getModelFromString: function(model_string){
  	var model_type;
  	if(model_string=="Event"){
  		model_type = App.Modelss.Event;
  	} else if(model_string=="User"){
  		model_type = App.Modelss.User;
  	} else if(model_string=="TeamsheetEntry"){
  		model_type = App.Modelss.TeamsheetEntry;
  	} else if(model_string=="EventMessage"){
  		model_type = App.Modelss.Message;
  	} else if(model_string=="InviteResponse"){
  		model_type = App.Modelss.InviteResponse;
  	} else if(model_string=="InviteReminder"){
      model_type = App.Modelss.InviteReminder;
    } else if(model_string=="EventResult"){
      model_type = App.Modelss.Event;
    }
  	return model_type;
  },*/

});