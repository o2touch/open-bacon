/**
 * Activity Item - used on User, Team and Event pages
 */
BFApp.Views.ActivityItemLayout = Marionette.Layout.extend({

  className: "activity-item",

  tagName: "li",

  template: "backbone/templates/activity_feed/activity_item_layout",

  regions: {
    activityItem: ".activity-text-content",
    comments: ".activity-item-comments-container",
    commentForm: ".activity-comment-form-container"
  },

  events: {
    "click .star": "toggleStar",
    "click .activity-item-like": "toggleLike",
    "click .toggle-comment-form": "toggleCommentForm",
    "keypress .comment-input": "submitComment",
    "focus .comment-input": "focusCommentInput",
  },

  ui: {
    "star": ".star",
    "likeLink": ".activity-item-like"
  },



  initialize: function(options) {
    this.context = options.context;
    this.isSetup = false;

    // listen for changes on the subj (user) e.g. the user changes their name/pic.
    // JO 24.06.13 - this doesn't work and I don't know why
    // Must be a problem with the association in the backbone relational store
    // between different user objects with the same ID
    //this.listenTo(this.model.get("subj"), "change", this.render);

    this.itemType = this.model.getActivityItemType();
    var classes = this.getClassName();
    // if this is a message item
    if (this.itemType == "MESSAGECREATED" && this.model.get("obj")) {
      var type = this.model.get("obj").getType();
      // add the message type as a class so we can style differently
      classes += " msg-type-" + type;
      // the isStarred method will only return true if the context is right
      if (this.model.isStarred()) {
        classes += " starred";
      }
    }
    this.$el.addClass(classes);
  },

  onShow: function() {
    $(".tipsy").remove();
    this.ui.star.tipsy({
      gravity: 'se'
    });
  },

  serializeData: function() {
    // we only show the star if it's a message, you're the organiser,
    // and the context is right, and it's not a placeholder
    var showStar = (!this.model.get("placeholder") &&
      this.itemType == "MESSAGECREATED" && this.options.isOrganiser &&
      this.context == this.model.get("obj").getType());
    var fromLeague = false;
    var htmlPic;
    if (this.model.get("obj").get("messageable_type") == "Division") {
      htmlPic = BFApp.renderProfilePicture({
        src: this.model.get("obj").get("messageable").league.logo_small_url,
        srcDefault: App.Modelss.League.prototype.defaults.logo_small_url,
        size: "small",
        type: "league",
        title: this.model.get("obj").get("messageable").league
      });
      fromLeague = true;
    } else {
      htmlPic = this.model.get("subj").getPictureHtml("small");
    }

    return {
      htmlPic: htmlPic,
      fromLeague: fromLeague,
      activity_item: this.model,
      date: moment(this.model.get("created_at")).fromNow(),
      starred: this.model.isStarred(),
      placeholder: this.model.get("placeholder"),
      alreadyLiked: this.model.likedByUser(ActiveApp.CurrentUser),
      showStar: showStar
    };
  },

  toggleStar: function() {

    var newStarredValue = !this.ui.star.hasClass("selected");

    /* force UI to update */
    if (newStarredValue) {
      this.$el.addClass("starred");
      this.ui.star.addClass("selected");
    } else {
      this.$el.removeClass("starred");
      this.ui.star.removeClass("selected");
    }
    $(".tipsy").remove();

    /* update the model (and tell the BE) and re-sort the collection */
    this.model.setStarred(newStarredValue);
    this.collection.sort();

  },

  getClassName: function() {
    var eventClass;
    if (this.itemType == "EVENTCREATED") {
      eventClass = "event-created";
    } else if (this.itemType == "EVENTUPDATED") {
      eventClass = "event-updated";
    } else if (this.itemType == "EVENTCANCELLED") {
      eventClass = "event-cancelled";
    } else if (this.itemType == "EVENTACTIVATED") {
      eventClass = "event-cancelled"; //Leo to add specific styling
    } else if (this.itemType == "TEAMSHEETENTRYADDEDTO") {
      eventClass = "event-invite";
    } else if (this.itemType == "MESSAGECREATED") {
      eventClass = "event-message";
    } else if (this.itemType == "INVITERESPONSECREATED") {
      eventClass = "event-response";
    } else if (this.itemType == "INVITEREMINDERSENT") {
      eventClass = "invite-reminder";
    } else if (this.itemType == "EVENTRESULTUPDATED") {
      eventClass = "event-score-updates";
    } else if (this.itemType == "EVENTPOSTPONED") {
      eventClass = "event-postponed";
    }

    return eventClass;
  },

  getAIView: function(options) {
    var view;

    if (this.itemType == "EVENTCREATED") {
      view = new BFApp.Views.EventCreatedActivityItem(options);
    } else if (this.itemType == "EVENTUPDATED") {
      view = new BFApp.Views.EventUpdatedActivityItem(options);
    } else if (this.itemType == "EVENTCANCELLED") {
      view = new BFApp.Views.EventCancelledActivityItem(options);
    } else if (this.itemType == "EVENTACTIVATED") {
      view = new BFApp.Views.EventActivatedActivityItem(options);
    } else if (this.itemType == "TEAMSHEETENTRYADDEDTO") {
      view = new BFApp.Views.TeamsheetActivityItem(options);
    } else if (this.itemType == "MESSAGECREATED") {
      view = new BFApp.Views.MessageActivityItem(options);
    } else if (this.itemType == "INVITERESPONSECREATED") {
      view = new BFApp.Views.InviteResponseActivityItem(options);
    } else if (this.itemType == "INVITEREMINDERSENT") {
      view = new BFApp.Views.InviteReminderActivityItem(options);
    } else if (this.itemType == "EVENTRESULTUPDATED") {
      view = new BFApp.Views.EventResultActivityItem(options);
    } else if (this.itemType == "EVENTPOSTPONED") {
      view = new BFApp.Views.EventPostponedActivityItem(options);
    } else if (this.itemType == "EVENTRESCHEDULED") {
      view = new BFApp.Views.EventRescheduledActivityItem(options);
    }

    return view;
  },

  focusCommentInput: function() {
    ActiveApp.CurrentUser.checkRegistered();
  },


  submitComment: function(e) {
    // if they hit enter
    if (e.keyCode == 13) {
      e.preventDefault();
      var len = this.$(".comment-input").val().trim().length;
      // just ignore when they submit empty comment
      if (len == 0) {
        return false;
      }
      var maxLen = 4000;
      if (len < maxLen) {
        this.createComment();
      } else {
        alert(BFApp.validation.msg.commentLength);
      }
    }
  },

  toggleLike: function() {
    if (ActiveApp.CurrentUser.checkRegistered()) {
      var newText;
      if ($.trim(this.ui.likeLink.text()) == "Like") {
        this.model.createLike(ActiveApp.CurrentUser);
        newText = "Unlike";
      } else {
        this.model.deleteLike(ActiveApp.CurrentUser);
        newText = "Like";
      }
      this.ui.likeLink.text(newText);
      this.updateLikesMarkup();
    }
    return false;
  },

  toggleCommentForm: function(forceShow) {
    if (ActiveApp.CurrentUser.checkRegistered()) {
      var commentForm = this.$(".activity-comment-form");
      if (commentForm.hasClass("hide") || forceShow === true) {
        // if showing the comment form on a starred item, show all comments
        if (this.model.isStarred()) {
          this.commentsView.showAllComments();
        }
        commentForm.removeClass("hide").find("input").focus();
      } else {
        commentForm.addClass("hide");
      }
    }
    return false;
  },

  createComment: function() {
    var that = this;

    var comment = new App.Modelss.ActivityItemComment();
    var attrs = {
      activity_item_id: this.model.get("id"),
      text: this.$(".comment-input").val().trim()
    };
    that.$(".comment-input").val("");
    comment.save(attrs, {
      error: function() {
        errorHandler();
      }
    });
    comment.set({
      user: ActiveApp.CurrentUser
    });
    this.model.get("comments").add(comment);

    return false;
  },

  onRender: function() {
    /*if (!this.model.get("obj") || !this.model.get("subj")) {
      //A scenario where obj may be null is when a teamsheet entry is deleted.
      //We should mark the records and deleted with a flag so activity feeds still display the origanal invitations.
      //We should add an activity feed notification to show the user has been removed from a game.
      //This check shouldnt activate because we filter the activity item collection before rendering.
      //See filterErronous function in ActivityItems.js
      return this;
    }

    if (this.itemType == "TEAMSHEETENTRYADDEDTO") {
      if (!this.model.get("obj").get("event") || !this.model.get("subj")) {
        return this;
      }
    } else if (this.itemType == "INVITERESPONSECREATED") {
      if (!this.model.get("obj").get("teamsheet_entry")) {
        return this;
      }
    }*/

    var activityItemContent = this.getAIView({
      context: this.context,
      model: this.model
    });
    this.activityItem.show(activityItemContent);

    if (!this.isSetup) {
      this.isSetup = true;

      // likes
      this.updateLikesMarkup();

      // comment form
      var commentForm = new BFApp.Views.ActivityItemCommentForm({
        show: !this.model.isStarred() && this.model.get("comments").length
      });
      this.commentForm.show(commentForm);

      // comments
      this.commentsView = new BFApp.Views.ActivityItemComments({
        collection: this.model.get("comments"),
        starred: this.model.isStarred()
      });
      this.comments.show(this.commentsView);
      this.listenTo(this.commentsView, "show:all", this.toggleCommentForm);
    }
  },

  updateLikesMarkup: function() {
    var likesHtml = '';
    var likes = this.model.get("likes");
    var nLikes = likes.length;

    if (nLikes > 0) {
      likesHtml += "<i class='bf-icon heart'></i> ";
      var isLikedByCurrentUser = likes.isLikedByCurrentUser();
      if (isLikedByCurrentUser) {
        likesHtml += "You";
        if (nLikes == 2) {
          likesHtml += " and " + likes.at(1).get("user").getLink();
        } else if (nLikes > 2) {
          likesHtml += " and " + (nLikes - 1) + " others";
        }
      } else {
        if (nLikes == 1) {
          likesHtml += likes.at(0).get("user").getLink();
        } else {
          likesHtml += nLikes + " people";
        }
      }

      likesHtml += (nLikes == 1 && !isLikedByCurrentUser) ? " likes this" : " like this";
      likesHtml = "<div class='activity-like'>" + likesHtml + "</div>";
    }

    this.$(".activity-like-container").html(likesHtml);
  }

});