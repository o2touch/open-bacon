class Api::V1::EventMessagesController < Api::V1::ApplicationController
  skip_authorization_check only: [:index, :show, :update, :destroy]

  def create    
    @messageable = find_messageable
    raise InvalidParameter.new, "Invalid" if @messageable.nil?

    authorize! :create_message, @messageable

    params[:message][:recipients] ||= {}

    recipients = params[:message][:recipients].to_json #If we dont this then its stored as obj 'ruby/hash:ActiveSupport::HashWithIndifferentAccess'
    recipients = JSON.parse(recipients)

    raise InvalidParameter.new, "Invalid Recipients" if validate_recipient_groups(recipients['groups']) == false

    #Dont mix this up with permission checking for this action!
    raise InvalidParameter.new, "Invalid Roles" if validate_roles(current_user, @messageable) == false
    
    if (!(@messageable.class != DivisionSeason) and !authorized_recipient_groups(recipients['groups']))
      raise InvalidParameter.new, "Unauthorized Recipients"
    end

    raise InvalidParameter.new, "Invalid Recipients" if validate_recipients(recipients['users'], @messageable) == false

    ActiveRecord::Base.transaction do # create message, create AI, star AI
      @event_message = @messageable.messages.create!(
        text: params[:message][:text],
        user: current_user,
        meta_data: { 'recipients' => recipients },
        sent_as_role_type: params[:message][:role_type],
        sent_as_role_id: params[:message][:role_id]
      )

      emo = EventMessageHelper.new
      emo.create_activity_item(@event_message)
      emo.push_create_to_feeds(@event_message)

      #Problem here is that this action is seperate and has seperate permission logic. I think this action needs to be in another method.
      if params[:message][:starred] == true
        #Move logic into something smarter that is returned from the messageable
        if @messageable.class != League and @messageable.class != DivisionSeason
          @team = (@messageable.class != Team) ? @messageable.team : @messageable
          authorize! :manage, @team
        else
          authorize! :update, @messageable
        end

        ai = @event_message.activity_item
        ai.meta_data = { :starred => params[:message][:starred], :starred_at => Time.now }.to_json
        ai.save!

        #doing this because new mobile activity feed index expects starred messages on team activity feed which does not exist in the website
        ai.push_to_redis(@messageable, :activity) unless !@messageable.acts_as_feedable? and ai.fetch_from_redis(@messageable, feed_type).nil?
        if @messageable.is_a?(Team)
          ai.push_to_redis(@messageable, :profile) unless !@messageable.acts_as_feedable? and ai.fetch_from_redis(@messageable, feed_type).nil?
        end
      end
    end
    AppEventService.create(@event_message, current_user, "created")

    render template: "api/v1/event_messages/show", formats: [:json], status: :ok
  end

  #If you implement you MUST remove the action from skip_authorization_check above!
  def index
    # look up by messageable type and id
    head :not_implemented
  end

  def show
    head :not_implemented
  end

  def update
    head :not_implemented
  end

  def destroy
    head :not_implemented
  end

  private
  def validate_roles(user, messageable)
    if messageable.respond_to?(:league)
      return messageable.league.has_organiser?(user)
    elsif (messageable.respond_to?(:team) || messageable.is_a?(Team))
      team = messageable.respond_to?(:team) ? messageable.team : messageable
      return team.has_active_member?(user)
    end

    false
  end

  def validate_recipients(recipients, messageable)
    return true if recipients.nil? or recipients.empty?

    return false if recipients.any? { |x| x.nil? or (x.to_i == 0) }

    users = recipients.map { |x| User.find(x) }

    members = messageable.class == Team ? messageable.members : messageable.invitees
    return false if users.any? { |x| members.include?(x) == false } 
    
    true
  end

  def validate_recipient_groups(groups)
    return true if groups.nil? or groups.empty?

    group_values = MessageGroups.values
    return false if groups.any? { |x| x.nil? or (x.to_i == 0) or (group_values.include?(x.to_i) == false) }

    true
  end

  def authorized_recipient_groups(groups)
    return true if groups.nil? or groups.empty?

    group_values = [MessageGroups::UNAVAILABLE, MessageGroups::ALL]
    return false if groups.any? { |x| group_values.include?(x.to_i) == true }

    true
  end

  def find_messageable  
    message_params = params[:message]
    message_params.each do |name, value|  
      if name =~ /(.+)_id$/ and ['team', 'event', 'division'].include?($1)
        match = "division_season" if $1 == "division" # so front end don't need to know about DS
        match ||= $1
        return match.classify.constantize.find_by_id(value)  
      end  
    end  
    nil  
  end 
end