BFApp.Views.WidgetEventRow = BFApp.Views.EventRow.extend({

  customSerializeData: function(data) {
    var timeObject = this.model.getDateObj(),
      clubName = this.model.get("club_name") || "",
      eventTitle = this.model.get("title");

    // on event page we use the team name instead
    // TS says this is fine because it contains the club name
    if (!clubName && window.ActiveApp && ActiveApp.Event) {
      clubName = ActiveApp.Event.get("team").get("name");
    }

    var titleString = clubName;
    if (clubName && eventTitle) {
      titleString += " - ";
    }
    titleString += eventTitle;

    // in this case we just put the date as the title
    data.title = timeObject.format("ddd, Do MMM h:mma");
    data.location = ""; // just ram everything into the time string (below)
    data.time = titleString;
    data.href = this.getEventLink();
    data.linkNewTab = true;
    // price now goes on it's own line
    data.extraEventDetails = this.model.getPriceString();
  },

  customRender: function() {
    if (!this.options.hideJoin) {
      BFApp.renderTemplate(this.$el, "map_search/join_event_button", {
        href: this.getEventLink()
      });
    }
  },

  getEventLink: function() {
    return this.model.getHref() + "?join=true";
  }

});