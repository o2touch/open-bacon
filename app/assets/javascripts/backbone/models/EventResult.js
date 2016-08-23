App.Modelss.EventResult = Backbone.RelationalModel.extend({

  relations: [{
    type: Backbone.HasOne,
    key: 'event',
    relatedModel: 'App.Modelss.Event'
  }]
  
});