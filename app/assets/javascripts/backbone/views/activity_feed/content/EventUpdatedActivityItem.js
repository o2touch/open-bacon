BFApp.Views.EventUpdatedActivityItem = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/content/event_updated",

  initialize: function(options) {
    this.context = options.context;

    this.prettyAttributeMap = {
      'location_id': 'Location',
      'title': 'Title',
      'game_type': 'Game Type',
      //'team_id': 'Team', The user can no longer assign an event to another team.
      'time': 'Time'
    };
  },

  serializeData: function() {
    var data = {
      user: this.model.get("subj"),
      isEventPage: (this.context == "event")
    };

    var updated_attrs = this.getUpdatedAttributes();

    // on the event page we display all the update details
    // on the team page, just a list of names
    if (this.context == "event") {
      data.attrs = updated_attrs;
    } else {
      var names = _.map(updated_attrs, function(p) {
        return p.name.toLowerCase();
      });
      names.sort();
      // store formatted list of attr names
      data.attrsString = names.join(", ").replace(/,([^,]*)$/, " and$1");
      data.event = this.model.get("obj");
    }

    return data;
  },

  getUpdatedAttributes: function() {
    var that = this;
    var updated_attrs = new Array();
    if (this.model.get("meta_data") != null) {
      var updates = $.parseJSON(this.model.get("meta_data"));

      _.each(updates, function(value, attr) {
        var prettyAttr = that.prettyAttribute(attr, value[0], value[1]);
        if (prettyAttr != null) {
          updated_attrs.push(prettyAttr);
        }
      });
    }
    return updated_attrs;
  },

  prettyAttribute: function(attr, oldValue, newValue) {

    if (attr in this.prettyAttributeMap == false) {
      return null;
    }

    var prettyAttribute = {
      name: this.prettyAttributeMap[attr],
      oldValue: this.formatAttributeValue(attr, oldValue),
      newValue: this.formatAttributeValue(attr, newValue)
    };

    return prettyAttribute;
  },

  formatAttributeValue: function(attr, value) {
    //Example value: {"old":{"id":1,"value":"Real Santa Monica Lions"},"new":null}
    //Example value: {"time":{"old":"2012-12-19T17:44:45Z","new":"2012-12-19T17:00:00Z"}}

    value = (value != null && typeof(value) === 'object') ? value['value'] : value;

    if (attr == 'time') {
      value = moment.utc(value).getMediumDateTime();
    }

    var blanker = (attr == 'team_id') ? 'no team' : 'blank';
    return (value == null || value === "") ? blanker : "'" + value + "'";
  }

});