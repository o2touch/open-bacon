class Admin::EmailPreviewController < Admin::AdminController
  include TeamUrlHelper
  include DivisionUrlHelper

	layout 'notifier'

	def index
		render layout: 'admin'
	end

  def bluefields_invite
    @invited_by = User.first
    @bluefields_invite = BluefieldsInvite.new
    render '/user_mailer/bluefields_invite', :layout => 'notifier'
  end
  
  def schedule
    @invitee = User.first
    @events = @invitee.future_events
    @team = Team.first
    @bluefields_invite = BluefieldsInvite.new
    @league = League.first
    render 'user_mailer/event_schedule', :layout => 'notifier'
  end
  
  def registration_confirmation
    @user = User.first
    render 'user_mailer/user_registered_confirmation', :layout => 'notifier'
  end

  ## Not used 
  # def team_invite_accepted
  #   @player = User.first
  #   @organiser = User.last
  #   @team = Team.first
  #   @team_invite = TeamInvite.first
  #   render 'user_mailer/team_invite_accepted', :layout => 'notifier'
  # end
  
  def team_message_posted
    @team = Team.first
    @message = EventMessage.create(:text => "A comment about the game", :messageable => @team, :user => User.last)
    @poster = @message.user
    @user = User.first
  
    render 'user_mailer/team_message_posted', :layout => 'notifier'
  end
  
  def event_reminder
    @user = User.first
    @event = Event.first
    @teamsheet_entry = TeamsheetEntry.first
    @day_of_week = "on " + @event.time.in_time_zone(@event.time_zone).strftime('%A')
    render 'user_mailer/event_reminder', :layout => 'notifier'
  end
  
  def invite
    @user = User.first
    @event = Event.first
    @teamsheet_entry = TeamsheetEntry.first
    render 'user_mailer/invite', :layout => 'notifier'
  end

  def event_details_updated
    @user = User.first
    @event = Event.first
    @teamsheet_entry = TeamsheetEntry.first
    time = BFTimeLib.bf_format(@event.time_local)
    @updates = { 
      'Time' => time, 
      'Location' => @event.location,
      'Title' => @event.title
    }

    render 'user_mailer/event_details_updated', :layout => 'notifier'
  end
  
  def event_cancelled
    @user = User.first
    @event = Event.first
    @teamsheet_entry = TeamsheetEntry.first
    render 'user_mailer/event_cancelled', :layout => 'notifier'
  end
  
  def event_schedule_update
    @invitee = User.first
    @events = @invitee.future_events
    @team = Team.first
    @bluefields_invite = BluefieldsInvite.new
    render 'user_mailer/event_schedule_update', :layout => 'notifier'
  end

  def event_schedule_update_single
    @invitee = User.first
    @events = [@invitee.future_events.first]
    @team = Team.first
    @bluefields_invite = BluefieldsInvite.new
    render 'user_mailer/event_schedule_update', :layout => 'notifier'
  end

  def invite_reminder
    @teamsheet_entry = TeamsheetEntry.first
    render 'user_mailer/invite_reminder', :layout => 'notifier'
  end
  
  def contact_form
    @email = "andy@bf.com"
    @message = "bluefields is amazing"
    @name = "andy gibson"
    @organisation = "andy gibson company"
    render 'user_mailer/contact_form', :layout => 'notifier'
  end
  
  def invite_response_notification
    @organiser = User.last
    @responder = User.first
    @event = Event.first
    @teamsheet_entry = TeamsheetEntry.first
    @invite_response = TeamsheetEntry.find(@responder)
    render 'user_mailer/invite_response_notification', :layout => 'notifier'
  end
  
  
  def new_user_invited_to_team
    @organiser = User.last
    @user = User.first
    @team = Team.first
    
    @team_invite = TeamsheetEntry.first
    render 'user_mailer/new_user_invited_to_team', :layout => 'notifier'
  end
  
  # def new_junior_invited_to_team
  #   @organiser = User.last
  #   @parent = User.first
  #   @junior = User.find(2)

  #   @team = Team.first
  #   @team_invite = TeamsheetEntry.first
  #   render 'user_mailer/new_junior_user_invited_to_team', :layout => 'notifier'
  # end

  def event_activated
    @user = User.first
    @event = Event.first
    @organiser = User.last
    @time_zone_mismatch = false

    render 'user_mailer/event_activated', :layout => 'notifier'    
  end

  def organiser_role_revoked_from_user
    @user = User.first
    @team = Team.first

    render 'user_mailer/organiser_role_revoked_from_user', :layout => 'notifier'    
  end

  def organiser_role_granted_to_user
    @user = User.first
    @team = Team.first

    render 'user_mailer/organiser_role_granted_to_user', :layout => 'notifier'    
  end

  def user_removed_from_team
    @user = User.first
    @team = Team.first

    render 'user_mailer/user_removed_from_team', :layout => 'notifier'   
  end

  def team_organiser_notification__new_user_invited_to_team
    @organiser = User.last
    @user = User.first
    @team = Team.first

    render 'user_mailer/team_organiser_notification__new_user_invited_to_team', :layout => 'notifier'   
  end

  def team_organiser_notification__organiser_role_revoked_from_user
    @organiser = User.last
    @user = User.first
    @team = Team.first

    render 'user_mailer/team_organiser_notification__organiser_role_revoked_from_user', :layout => 'notifier'   
  end

  def team_organiser_notification__organiser_role_granted_to_user
    @organiser = User.last
    @user = User.first
    @team = Team.first

    render 'user_mailer/team_organiser_notification__organiser_role_granted_to_user', :layout => 'notifier'   
  end

  def team_organiser_notification__user_removed_from_team
    @organiser = User.last
    @user = User.first
    @team = Team.first

    render 'user_mailer/team_organiser_notification__user_removed_from_team', :layout => 'notifier'   
  end

  def league_event_schedule
    @organiser = User.last
    @team = Team.first
    @invitee = User.first
    @events = @team.future_events
    @league = League.first

    render 'league_mailer/event_schedule', :layout => 'notifier'   
  end

  def league_organiser_role_granted_to_user
    @user = User.last
    @team = Team.first
    @league = League.first

    render 'league_mailer/organiser_role_granted_to_user', :layout => 'notifier'  
  end

  def league_user_invited_to_team
    @team = Team.first
    team_role = @team.team_roles.where(:role_id => 1).where("user_id NOT IN (?)", @team.organisers.map(&:id)).first
    @team_invite = TeamInvite.get_invite(@team, team_role.user, nil) 
    @user = @team_invite.sent_to
    @team = @team_invite.team
    @league = League.first
    @organiser = @team_invite.sent_by

    render 'league_mailer/user_invited_to_team', :layout => 'notifier'  
  end

  def comment_from_email_failure
    render 'user_mailer/comment_from_email_failure', :layout => 'notifier'
  end

  def result_created
    @recipient = User.find(6623)
    @team = Team.find(162072)
    @fixture = @team.events.first.fixture
    @result = @fixture.result
    @league = @team.divisions.first.league
    @token = PowerToken.generate_token(default_team_path(@team), @recipient)

    # fuck some shit up!
    @_message = Object.new
    @_message.define_singleton_method(:to){ "tpsherratt@googlemail.com" }

    render 'result_mailer/member_result_created', :layout => 'notifier'
  end

  def division_result_created
    @recipient = User.find(6623)
    @team = Team.find(162072)
    @fixture = @team.events.first.fixture
    @division = @fixture.division
    @result = @fixture.result
    @league = @division.league
    @token = PowerToken.generate_token(default_division_path(@division), @recipient)

    # fuck some shit up!
    @_message = Object.new
    @_message.define_singleton_method(:to){ "tpsherratt@googlemail.com" }

    render 'result_mailer/member_division_result_created', :layout => 'notifier'
  end


end
