BFApp.Views.ActivityMessageWidget = Marionette.ItemView.extend({

  template: "backbone/templates/activity_feed/add_message_widget",

  className: "post-message",

  tagName: "form",

  events: {
    "click button[title='add message']": "addMessage",
    "keyup .message-area": "updateButtonState",
    "click .star": "toggleStar",
    "focus .message-area": "messageFocus",
    "blur .message-area": "messageBlur",

    "click .show-groups-dropdown": "clickGroupsButton",
    "click .group-of-players": "selectUsersGroup"
  },

  ui: {
    "messageTextarea": ".message-area",
    "postButton": "button[title='add message']",
    "star": ".star",
    "actionBar": "footer",
    "dropdownArea": ".msg-groups",
    "showGroupsDropdown": ".show-groups-dropdown",
    "groupsDropdown": ".groups-dropdown",
    "groupsOfPlayers": ".group-of-players"
  },

  initialize: function(options) {
    this.context = options.context;
    this.isOrganiser = options.isOrganiser;
    this.divisionId = options.divisionId;
  },

  onShow: function() {
    var that = this;
    this.ui.star.tipsy({
      gravity: 'se'
    });

    if (this.context == "event") {
      this.$el.find(".awaiting, .available").addClass("selected");
      this.$el.outside("click", function() {
        that.hideDropdown();
      });
    }
  },

  selectUsersGroup: function(e) {
    var elementObject = $(e.currentTarget);
    $(elementObject).toggleClass("selected");
  },

  messageFocus: function() {
    this.$el.addClass("active textarea-focus");
    this.ui.messageTextarea.autosize({
      className: 'mirroredText',
      append: "\n"
    });
  },

  messageBlur: function() {
    this.$el.removeClass("textarea-focus");
  },

  toggleStar: function() {
    this.ui.star.toggleClass("selected");
    if (this.ui.star.hasClass("selected")) {
      this.ui.star.attr("original-title", "Remove from highlights");
    } else {
      this.ui.star.attr("original-title", "Highlight");
    }
    return false;
  },

  clickGroupsButton: function() {
    this.ui.showGroupsDropdown.toggleClass("open");
    this.ui.groupsDropdown.toggleClass("hide");
  },

  hideDropdown: function() {
    this.ui.showGroupsDropdown.removeClass("open");
    this.ui.groupsDropdown.addClass("hide");
  },


  updateButtonState: function() {
    var disableButton = (this.ui.messageTextarea.val().trim().length == 0);
    this.ui.postButton.prop("disabled", disableButton);
  },

  serializeData: function() {
    var messagePlaceholder;

    if (this.context == "event") {
      if (this.isOrganiser) {
        messagePlaceholder = "Message the players...";
      } else {
        messagePlaceholder = "Post a message...";
      }
    } else if (this.context == "league") {
      messagePlaceholder = "Message this division...";
    } else {
      if (this.isOrganiser) {
        messagePlaceholder = "Message the team...";
      } else {
        messagePlaceholder = "Message the team...";
      }
    }

    var groups,
      copy = ActiveApp.Tenant.get("general_copy").availability;
    if (this.context == "event") {
      groups = [{
        "className": "available",
        "name": "Players " + copy.available,
        "selected": "selected",
        "id": 1
      }, {
        "className": "awaiting",
        "name": "Players " + copy.awaiting,
        "selected": "selected",
        "id": 2
      }, {
        "className": "unavailable",
        "name": "Players " + copy.unavailable,
        "selected": "",
        "id": 3
      }];
    } else {
      groups = [];
    }

    return {
      isOrganiser: this.isOrganiser,
      groups: groups,
      messagePlaceholder: messagePlaceholder,
      showStar: this.isOrganiser && this.context !== "league"
    };
  },

  validate: function() {
    var msg = BFApp.validation.validateInput({
      htmlObject: this.ui.messageTextarea,
      maximumLength: 4000,
      maximumLengthMessage: BFApp.validation.msg.messageLength
    });

    return msg;
  },

  getSelectedGroups: function() {
    var groupElems = this.ui.groupsOfPlayers.filter(".selected[data-id]");
    var groupIds = groupElems.map(function() {
      return $(this).attr("data-id");
    });
    return groupIds.toArray();
  },

  addMessage: function(e) {
    this.$el.find(".alert-box.alert").remove();
    var that = this;
    var messageText = this.ui.messageTextarea.val().trim();
    if (messageText.length == 0) {
      return false;
    }

    if (this.validate()) {
      disableButton(this.ui.postButton);
      that.$el.addClass("textarea-disabled");
      var attrs = {
        text: messageText,
        recipients: {
          //users: NOT YET
          groups: this.getSelectedGroups()
        }
      };
      // BE asked us not to send the starred attr if it was false
      // as would be perms issue with a player trying to set the value to false
      if (this.ui.star.hasClass("selected")) {
        attrs.starred = true;
      }

      /*
        Server logic
        ------------
        message on league
          division_id   => ID of division
          role_type     => "League" (case sensitive)
          role_id       => 1 (admin)

        message on event/team
        event_id        => ID of event/team
        role_type       => "Event" or "Team" (case sensitive)
        role_id         => 1 (player) or 2 (admin)
      */

      var contextId;
      if (this.context == "event") {
        attrs.event_id = contextId = ActiveApp.Event.get("id");
        attrs.role_type = "Team";
        attrs.role_id = (this.isOrganiser) ? 2 : 1;
      } else if (this.context == "team") {
        attrs.team_id = contextId = ActiveApp.ProfileTeam.get("id");
        attrs.role_type = "Team";
        attrs.role_id = (this.isOrganiser) ? 2 : 1;
      } else if (this.context == "league") {
        attrs.division_id = contextId = this.divisionId;
        attrs.role_type = "League";
        attrs.role_id = 1;
      }


      var options = {
        success: function(model, response, options) {
          that.ui.messageTextarea.val('');
          enableButton(that.ui.postButton);
          that.ui.postButton.prop("disabled", true);

          // display a placeholder activity item while we wait for pusher
          that.trigger("add:message", model);
          that.$el.removeClass("textarea-disabled");
          that.ui.star.removeClass("selected");
          that.hideDropdown();
          that.ui.messageTextarea.css({
            "height": "50px"
          })
        },
        error: function(model, xhr, options) {
          that.trigger("remove:message", attrs);
          errorHandler({
            button: that.ui.postButton
          });
          that.ui.postButton.prop("disabled", true);
          that.$el.removeClass("textarea-disabled");
          that.hideDropdown();

        }
      };


      var message = new App.Modelss.Message();
      message.save(attrs, options);

      analytics.track('Posted Message', {
        "context": this.context,
        "context_id": contextId
      });
    }

    return false;
  }

});