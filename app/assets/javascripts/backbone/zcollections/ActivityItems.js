App.Collections.ActivityItems = Backbone.LiveCollection.extend({

  model: App.Modelss.ActivityItem,

  url: "/api/v1/activity_items",

  fetch: function(options) {
    options || (options = {});
    options.data || (options.data = {});

    var defaultData = {
      starred: -1,
      item_count: 20,
      feed_type: options.feed_type
    };
    _.defaults(options.data, defaultData);

    return Backbone.Collection.prototype.fetch.call(this, options);
  },

  // override Backbone Collection.add to make sure that if any new models being added 
  // should replace existing placeholders then those placeholders get removed
  add: function(models, options) {
    // backbone allows you to send a single model (non-array)
    models = (_.isArray(models)) ? models : [models];

    // find any existing placeholders
    var fakeMessageItems = this.where({
      placeholder: true,
      obj_type: "EventMessage",
      verb: "created"
    });

    if (fakeMessageItems.length) {
      var that = this;
      _.each(models, function(model) {
        if (model.obj !== null && model.subj !== null && model.id && model.obj_type == "EventMessage" && model.verb == "created") {
          // check if this new model has the same message ID as one of the fakes
          _.each(fakeMessageItems, function(fakeMessageItem) {
            if (fakeMessageItem.get("obj").get("id") == model.obj.id) {
              that.remove(fakeMessageItem);
            }
          });
        }
      });
    }

    return Backbone.Collection.prototype.add.call(this, models, options);
  },

  // override Backbone Collection.set
  set: function(models, options) {
    // filter out faulty data
    // JACK TODO - remove this when the BE does it...
    models = _.filter(models, function(model) {
      var result;
      // new case: if already instanciated, none of the following applies (just return true)
      if (model.attributes) {
        result = true;
      } else if (!model.obj || !model.subj) {
        result = false;
      }
      // check for delete events (id of -1)
      else if (model.obj_type == "EventResult" || model.obj_type == "TeamsheetEntry") {
        result = (model.obj.event && model.obj.event.id != -1);
      } else if (model.obj_type == "InviteReminder" || model.obj_type == "InviteResponse") {
        result = (model.obj.teamsheet_entry && model.obj.teamsheet_entry.event &&
          model.obj.teamsheet_entry.event.id != -1);
      } else if (model.obj_type == "EventMessage") {
        result = (model.obj.messageable != null && model.obj.messageable.id != -1);
      } else {
        // in all other situations, the obj is the event
        result = (model.obj.id != -1);
      }

      //console.log("result = "+result+" for ai = %o", model);
      return result;
    });

    return Backbone.Collection.prototype.set.call(this, models, options);
  },

  // helper function to compare 2 ISO timestamps
  compareISOs: function(aISO, bISO) {
    var a = moment(aISO).valueOf();
    var b = moment(bISO).valueOf();
    if (a == b) {
      return 0;
    }
    return (a < b) ? 1 : -1;
  },

  // descending
  comparator: function(a, b) {
    // console.log("COMPARING");
    // console.log(a.get("name"));
    // console.log(b.get("name"));
    var result;
    if (a.isStarred()) {
      if (b.isStarred()) {
        //console.log("both starred");
        result = this.compareISOs(a.get("starred_at"), b.get("starred_at"));
      } else {
        // a comes first
        //console.log("only a starred");
        result = -1;
      }
    } else if (b.isStarred()) {
      // b comes first
      //console.log("only b starred");
      result = 1;
    } else {
      //console.log("neither starred");
      result = this.compareISOs(a.get("created_at"), b.get("created_at"));
    }
    //console.log("result = " + result);
    return result;
  }

});