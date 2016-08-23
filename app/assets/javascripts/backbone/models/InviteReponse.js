App.Modelss.InviteResponse = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'teamsheet_entry',
    relatedModel: 'App.Modelss.TeamsheetEntry'
  }]

});