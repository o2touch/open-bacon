class AggregateMessageManager
def initialize
    @bucket_hash = {}
  end

  def create_team_bucket(team_id)
    id = "team-#{team_id.to_s}"
    
    flushing_strategy = DrinkingBirdFlushingStrategy.new(30.seconds) #TODO Read time from Onyx options.
    processor = NotificationItemTeamRoleAg.new(team_id)

    RollUpBucket.new(id, flushing_strategy, processor)
  end

  def bucket_message(message_p)    
    # We need a similar construct to a message router
    # we should do something if the bucket rejects the message
    message = JSON.parse(message_p)['args'][0]

    message_obj = message['class'].constantize.find(message['id'])
    
    if ['destroyed', 'created'].include?(message_obj.verb) and [TeamInvite.name, PolyRole.name].include?(message_obj.obj_type)
      team_id = message_obj.obj ? message_obj.obj.team_id : message_obj.meta_data[:team_id]
      id = "team-#{team_id.to_s}"
      
      if @bucket_hash.has_key?(id)
        bucket = @bucket_hash[id]
      else 
        bucket = create_team_bucket(team_id)
        @bucket_hash[id] = bucket
      end 

      bucket.add_item(message_obj)
    end
  end
end
