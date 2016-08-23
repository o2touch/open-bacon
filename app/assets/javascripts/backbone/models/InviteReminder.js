App.Modelss.InviteReminder = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'teamsheet_entry',
    relatedModel: 'App.Modelss.TeamsheetEntry'
  }]
  
});