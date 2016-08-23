BFApp.Views.ScheduleNavigation = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/schedule/schedule_navigation",
  className:"schedule-navigation clearfix classic",
  tagName:"form",

  events: {
    "keyup .schedule-search": "searchChange",
    "click .schedule-search-close": "clearSearch"
  },
  
  

  ui: {
    "search": ".schedule-search",
    "searchReset": ".schedule-search-close",
    "editButton": ".schedule-edit",
    "viewButton": ".schedule-view",

    "editModeNavi": ".edit-mode",
    "viewModeNavi": ".view-mode"
  },

  initialize: function(options) {
    this.editMode = options.editMode;
  },

  serializeData: function() {
    var canManageTeam = ActiveApp.Permissions.get("canManageTeam");
    // only show search if >3 events
    var showSearch = (this.collection.length > 3);
    return {
      emptySchedule: (this.collection.length == 0),
      canManageTeam: canManageTeam,
      showSearch: showSearch,
      showNav: (showSearch || canManageTeam)
    };
  },  

  clearSearch: function() {
    this.ui.search.val('').keyup();
    return false;
  },

  searchChange: function(e) {
    if(keyIsCharacter(e.keyCode)){
      this.trigger("event:filter");
      if(this.ui.search.val()==""){
        this.ui.searchReset.addClass("hide");
      }else{
        this.ui.searchReset.removeClass("hide");
      }
    }
  },

  enableEditMode: function(addNewEvent) {
    this.ui.editModeNavi.removeClass("hide");
    this.ui.viewModeNavi.addClass("hide");
  },

  enableViewMode: function() {
    this.ui.editModeNavi.addClass("hide");
    this.ui.viewModeNavi.removeClass("hide");
  },

  onRender: function() {
    if (this.editMode) {
      this.enableEditMode();
    }
    this.$el.submit(function(){
      return false;
    });

    this.$("input, textarea").placeholder();
  }

});