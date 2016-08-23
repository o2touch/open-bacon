App.Modelss.ActivityItemObject = Backbone.RelationalModel.extend({

  subModelTypeAttribute: "obj_type",

  subModelTypes: {
    'TeamsheetEntry': 'App.Modelss.TeamsheetEntry',
    // JACK TODO - rename this from EventMessage to Message when BE changes it in obj_type
    'EventMessage': 'App.Modelss.Message',
    'Event': 'App.Modelss.Event',
    'User': 'App.Modelss.User',
    'InviteResponse': 'App.Modelss.InviteResponse',
    'InviteReminder': 'App.Modelss.InviteReminder',
    'EventResult': 'App.Modelss.EventResult'
  },

  // this is for Backbone Relational, we add the model type into the ID,
  // so it doesn't complain when the above sub-models (e.g. an Event and a User) have the same IDs
  idAttribute: "relationalId"

});