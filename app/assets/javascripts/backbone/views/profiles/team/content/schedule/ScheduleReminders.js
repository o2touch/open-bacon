BFApp.Views.ScheduleReminders = Marionette.ItemView.extend({


  template: "backbone/templates/profiles/team/content/schedule/schedule_reminders",
  className: "schedule-notification clearfix",
  
  events: {
    "click .send-schedule": "sendSchedule",
  },
  
  sendSchedule:function(){
    //send schedule fonction
  },
  

  
});