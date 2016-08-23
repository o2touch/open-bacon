SearchApp.Views.LeagueList = Marionette.CollectionView.extend({

  tagName: "ul",

  className: "team-list-results inner-search",

  itemView: SearchApp.Views.LeagueRow

});