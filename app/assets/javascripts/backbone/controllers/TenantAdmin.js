BFApp.Controllers.TenantAdmin = Marionette.Controller.extend({

  setup: function() {
    var that = this;

    var naviView = new BFApp.Views.NaviView();
    BFApp.navigation.show(naviView);

  }

});