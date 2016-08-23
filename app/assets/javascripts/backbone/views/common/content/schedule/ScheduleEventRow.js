/**
 * This is used on the User profile and Team profile schedule tabs
 */
BFApp.Views.ScheduleEventRow = Marionette.ItemView.extend({

    tagName: "div",

    className: "event-row",

    template: "backbone/templates/common/content/schedule/schedule_event_row",

    events: {
        'click .i-am-available': 'setAvailable',
        'click .i-am-not-available': 'setUnavailable',
        'click .prevent-click': 'preventClick'
    },

    preventClick: function(e) {
        e.preventDefault();
    },

    initialize: function(options) {
        this.currentLocation = this.model.get("location");
        this.listenTo(this.model, 'change', this.modelChange);
    },

    modelChange: function() {
        // if new location, start listening for changes
        var location = this.model.get("location");
        // when switch to new location object, we listen for changes
        if (location && location.isNew() && !location.hasChanged()) {
            this.stopListening(this.currentLocation);
            this.currentLocation = location;
            this.listenTo(this.currentLocation, "change", this.reRender);
        }

        this.reRender();
    },

    reRender: function() {
        // here we set changed=true so we know not to fade it in on render
        this.model.set("changed", true, {
            silent: true
        });
        this.render();
    },

    setAvailable: function(e) {
        this.$(".i-am-available").addClass("success");
        this.$(".i-am-not-available").removeClass("alert");
        this.model.markAvailable(this.tseUser);
        return false;
    },

    setUnavailable: function(e) {
        this.$(".i-am-available").removeClass("success");
        this.$(".i-am-not-available").addClass("alert");
        this.model.markUnavailable(this.tseUser);
        return false;
    },

    serializeData: function() {
        // only show team info if NOT on team page
        var teamModel = (!ActiveApp.ProfileTeam) ? this.model.get("team") : null;

        var perms = this.model.get("permissions") || {};

        // actions
        var canEditEvent = false;
        var canRespond = false;
        var justMeInvited = false,
            invitedChildName = "";
        var displayLock = false;

        // if on team profile page
        if (ActiveApp.ProfileTeam && ActiveApp.Teammates) {
            canEditEvent = perms.canEdit;
            // you get availability buttons if you have perms, and only 1 of you (you or your kids)
            // is invited AND you don't have perms to edit this event AND you're not the organiser of the team
            var canManageTeam = ActiveApp.Permissions.get("canManageTeam");
            var myInvitedUsers = ActiveApp.Teammates.getMyPlayersInTeam(ActiveApp.ProfileTeam);
            if (perms.canRespond && myInvitedUsers.length == 1 && !canEditEvent && !canManageTeam) {
                canRespond = true;
                this.tseUser = myInvitedUsers[0];
            }
            // if you are a team organiser, but can't edit an event, it must be locked
            displayLock = (canManageTeam && !canEditEvent);
        }
        // if on user profile page
        else if (ActiveApp.ProfileUser) {
            // you only get availability buttons if the profile you're viewing is either you or
            // one of your kids
            if (perms.canRespond && BFApp.uids.indexOf(ActiveApp.ProfileUser.get("id")) != -1) {
                canRespond = true;
                this.tseUser = ActiveApp.ProfileUser;
            }
        }
        this.$el.addClass('with-availability');
        // common to both pages
        if (canRespond) {

            if (this.tseUser.get("id") == ActiveApp.CurrentUser.get("id")) {
                justMeInvited = true;
            } else {
                invitedChildName = this.tseUser.getForename();
            }
        }

        var userStatus = (this.tseUser) ? this.model.userStatus(this.tseUser) : null;   
        var eventTime = this.model.getDateObj();  

        return {
            title: this.model.get("title") || "Title",
            timeTBC: this.model.get("time_tbc"),
            time: eventTime.getFormattedTime(),
            date: eventTime.date(),
            cutMonth: eventTime.format("MMM"),
            isCancelled: (this.model.get("status") == 1),
            isPostponed: (this.model.get("status") == 3),
            locationTitle: this.model.getLocationTitle(),
            userStatus: userStatus,
            teamModel: teamModel,
            canRespond: canRespond,
            justMeInvited: justMeInvited,
            invitedChild: invitedChildName,
            href: this.model.getHref(),
            canEditEvent: canEditEvent,
            rowType: this.options.rowType,
            showActions: (this.options.rowType !== "new"),
            displayLock: displayLock,
            copy: ActiveApp.Tenant.get("general_copy").availability,


            // Styling purpose
            color: this.model.get('game_type_string') == 'game' && this.model.get('team').get('colour1')
        };    
    },

    onRender: function() {

        this.$el.addClass('event-type-' + this.model.get('game_type_string'));

        //console.log("onRender for event model with title = "+this.model.get("title")+" and id="+this.model.get("id"));

        // hide the eventId in the data attribute of this element so we can access it when
        // the user clicks to edit
        this.$el.data("event-id", this.model.get("id"));

        this.$el.find(".lock").tipsy({
            gravity: 's'
        });

        //console.log("render event row with model.changed="+this.model.get("changed"));
        if (this.model.get("changed") == null) {
            this.$el.css({
                "opacity": "0"
            });
            this.$el.animate({
                "opacity": "1"
            }, BFApp.constants.animation.time, BFApp.constants.animation.easingIn);
        }

    }

});