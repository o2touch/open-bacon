var Split = {

  getAlternative: function(name) {
    var experiment;
    $.ajax({
      url: "/api/v1/split/alternative/"+name,
      type: "GET",
      async: false,
      success: function(data) {
        experiment = data;
      }
    });
    return experiment;
  },

  finishExperiment: function(name, on_success){
    $.ajax({
      url: "/api/v1/split/finished/"+name,
      type: "POST",
      success: on_success
    });
  }
};