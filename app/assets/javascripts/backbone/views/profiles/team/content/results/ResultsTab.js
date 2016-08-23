BFApp.Views.ResultsTab = Marionette.Layout.extend({

  template: "backbone/templates/profiles/team/content/results/results_tab",
  className: "main-content main-content-results",

  regions: {
    controls: "#r-results-controls",
    empty: "#r-results-empty",
    notice: "#r-results-notice",
    reminder: "#r-results-reminder",
    calendar: "#r-results-calendar",
    newEvent: "#r-results-new-event",
    eventList: "#r-results-event-list",
    schedulePopover: "#r-results-popover"
  },

  onRender: function() {
    var that = this;

    //Navigation & controls     
    this.navigation = new BFApp.Views.ResultsNavigation({
      collection: this.collection
    });
    this.controls.show(this.navigation);

    //search
    this.navigation.on("results-search:changed", function() {

      //perform search only if event exist
      if (that.collection.length > 0) {
        that.updateCollection();
      }
    });

    //Default collection
    this.resultsEventListView = new BFApp.Views.ResultsEventList({
      collection: this.collection
    });

    //empty message
    this.resultsEmptyView = new BFApp.Views.ResultsEmpty({
      isInTeam: ActiveApp.Permissions.get("canViewPrivateDetails")
    });



    //display depending of collection length
    if (this.collection.length > 0) {
      this.eventList.show(this.resultsEventListView);
    } else {
      this.empty.show(this.resultsEmptyView);
    }



  },


  updateCollection: function() {
    var that = this;
    this.searchText = this.navigation.ui.search.val();

    this.filteredCollection = new App.Collections.Events(that.collection.filter(function(events) {
      return events.get('title').toLowerCase().indexOf(that.searchText.toLowerCase().trim()) !== -1;
    }));

    this.resultsEventListView = new BFApp.Views.ResultsEventList({
      collection: this.filteredCollection
    });

    if (this.filteredCollection.length > 0) {
      
      //show event and hide empty view
      this.eventList.show(this.resultsEventListView);
      this.empty.close();
  
    } else {

      //set empty view on search mode
      this.resultsEmptyView = new BFApp.Views.ResultsEmpty({
        isInTeam: ActiveApp.Permissions.get("canViewPrivateDetails"),
        search: true
      });
      
      //hide event & show empty view
      this.empty.show(this.resultsEmptyView);
      this.eventList.close();
    }

  }


});