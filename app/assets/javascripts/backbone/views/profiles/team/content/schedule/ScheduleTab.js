/**
 * Schedule tab on the Team and User pages
 */
BFApp.Views.ScheduleTab = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/content/schedule/schedule_tab",
  className: "main-content main-content-schedule view-schedule-mode",

  editMode: false,

  scheduleChange: false,

  scheduleNavigationView: null,

  regions: {
    controls: "#r-schedule-controls",
    newEventPreview: "#r-schedule-new-event-preview",
    eventList: "#r-schedule-event-list",
    exportCalendar: "#r-schedule-export-calendar",
    schedulePopover: "#r-schedule-popover",
  },

  triggers: {
    "click .schedule-add-event": "add:event",
    "click .schedule-edit": "mode:edit",
    "click .schedule-view": "mode:done"
  },

  events: {
    "click .event-row": "clickedEventButton",
  },

  clickedEventButton: function(e) {
    if (this.editMode && !$(e.currentTarget).hasClass("new-event")) {
      var eventRow = $(e.currentTarget);
      this.highlightEvent(eventRow);
      var eventId = eventRow.data("event-id");
      var eventModel = ActiveApp.Events.get("event" + eventId);
      this.trigger("edit:event", eventModel);
      return false;
    }

  },

  highlightEvent: function(eventRow) {
    $(".event-row").removeClass("selected");
    $(eventRow).addClass("selected");
  },

  onRender: function() {
    // SETUP NEEDS     
    var that = this;

    //SCHEDULE NAVIGATION
    if (this.collection.length > 3 || ActiveApp.Permissions.get("canManageTeam")) {
      this.scheduleNavigationView = new BFApp.Views.ScheduleNavigation({
        collection: this.collection,
        editMode: this.editMode
      });

      this.controls.show(this.scheduleNavigationView);

      this.scheduleNavigationView.listenTo(this.collection, "add remove", function() {
        that.scheduleNavigationView.editMode = that.editMode;
        that.scheduleNavigationView.render();
      });

      // search events listener
      this.scheduleNavigationView.on("event:filter", function() {
        if (that.collection.length > 0) {
          var searchText = that.scheduleNavigationView.ui.search.val();

          var searchResults = new App.Collections.Event(_.filter(that.collection.models, function(e) {
            return e.get("title").toLowerCase().indexOf(searchText.toLowerCase().trim()) !== -1;
          }));

          that.eventsView.setCollection(searchResults);
        }
      });
    }

    //Export calendar
    if (ActiveApp.Permissions.get("canViewPrivateDetails") && !this.editMode) {
      var exportCalView = new BFApp.Views.ExportEventCalendarForm();
      this.exportCalendar.show(exportCalView);
    }

    // Display events / empty message
    this.eventsView = new BFApp.Views.ScheduleEventList({
      collection: this.collection
    });
    this.eventList.show(this.eventsView);

    return this;
  },

  enableEditMode: function(newEvent) {
    this.editMode = true;

    var addNewEvent = (newEvent != null);
    this.$(".empty").addClass("hide");

    this.scheduleNavigationView.enableEditMode(addNewEvent);
    this.$el.switchClass("view-schedule-mode", "edit-schedule-mode", 200);

    // hide the export cal link
    this.exportCalendar.close();

    // if adding a new event
    if (addNewEvent) {
      var eventRowView = new BFApp.Views.ScheduleEventRow({
        model: newEvent,
        rowType: "new",
        className: "event-row new-event"
      });
      this.newEventPreview.show(eventRowView);

    } else {
      this.eventsView.setCollection(this.collection);
      this.newEventPreview.close();
    }
  },

  enableViewMode: function() {
    this.editMode = false;

    this.scheduleNavigationView.enableViewMode();

    //Export calendar
    if (ActiveApp.Permissions.get("canViewPrivateDetails")) {
      var exportCalView = new BFApp.Views.ExportEventCalendarForm();
      this.exportCalendar.show(exportCalView);
    }

    if (ActiveApp.Events.length == 0) {
      this.$(".empty").removeClass("hide");
    }

    // change colours and icons
    this.$el.switchClass("edit-schedule-mode", "view-schedule-mode", 0);

    // close the new event preview
    this.newEventPreview.close();
  }

});