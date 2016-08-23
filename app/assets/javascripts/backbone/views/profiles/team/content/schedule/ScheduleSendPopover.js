BFApp.Views.ScheduleSendPopover = Marionette.ItemView.extend({

  template: "backbone/templates/profiles/team/content/schedule/schedule_send_popover",

  className: "schedule-popover",

  triggers: {
    "click .close-popover": "close:popover"
  },

  events: {
    "click .send-schedule": "sendSchedule"
  },

  ui: {
    "sendButton": ".send-schedule"
  },

  sendSchedule: function() {
    // disableButton({
    //   button: this.ui.sendButton,
    //   value: "Sending..."
    // });
    // 
    // // TESTING
    // this.trigger("schedule:sent");

    /*var that = this;
    $.ajax({
      type: "post",
      url: "/api/v1/teams/"+ActiveApp.ProfileTeam.get("id")+"/send_schedule",
      success: function(data) {
        console.log("success");
        that.trigger("schedule:sent");
      }
    });*/
  }

});