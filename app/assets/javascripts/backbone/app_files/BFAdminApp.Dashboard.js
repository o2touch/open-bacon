// BFAdminApp.module('Dashboard', function(Dashboard, App, Backbone, Marionette, $, _){

//   BFAdminApp.Router = Marionette.AppRouter.extend({
//     appRoutes : {
//       'boo': 'showNavi'
//     }
//   });

//   BFAdminApp.Controller = function(){
//     //this.DashboardObj = {}
//   };

//   _.extend(BFAdminApp.Controller.prototype, {

//     // Start the app by showing the appropriate views
//     // and fetching the list of todo items, if there are any
//     start: function(){
//       this.showNavi(this.DashboardObj);
//       //this.showFooter(this.todoList);
//       //this.showTodoList(this.todoList);

//       //this.todoList.fetch();
//     },

//     showNavi: function(DashboardObj){
//       var navi = new App.Layout.Navi({
//         //model: DashboardObj
//       });
//       BFAdminApp.navi.show(navi);
//     }
//   });

//   BFAdminApp.addInitializer(function(){

//     var controller = new BFAdminApp.Controller();
//     new BFAdminApp.Router({
//       controller: controller
//     });

//     controller.start();

//   });

// });