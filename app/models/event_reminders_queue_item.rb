# class EventRemindersQueueItem < ActiveRecord::Base
#   # Not used.
#   # But the idea is that it will email organisers to ok the auto-reminder
#   #  going out.
#   belongs_to :event
#   attr_accessible :event_id, :scheduled_time, :token
  
#   before_create :create_token
  
#   def create_token
#     token_length = 12      
#     self.token = rand(36**token_length).to_s(36)
#   end
  
#   def process
#     puts "PROCESS"
#     #num_reminders_sent = self.event.send_event_reminders
#     #self.delete
#     num_reminders_sent 
#   end
# end
