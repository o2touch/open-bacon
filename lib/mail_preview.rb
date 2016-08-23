unless Rails.env.test?
  require 'factory_girl'
  Dir[File.dirname(__FILE__) + '/../spec/factories/*'].each {|file| require file }
end

class MailPreview < MailView
  # # Pull data from existing fixtures
  # def invitation
  #   account = Account.first
  #   inviter, invitee = account.users[0, 2]
  #   Notifier.invitation(inviter, invitee) 
  # end

  # # Factory-like pattern
  # def welcome
  #   user = User.create!
  #   mail = Notifier.welcome(user)
  #   user.destroy
  #   mail
  # end

  # # Stub-like
  # def forgot_password
  #   user = Struct.new(:email, :name).new('name@example.com', 'Jill Smith')
  #   mail = UserMailer.forgot_password(user)
  # end

  ########
  # DIVISION MAILER
  ######
  def player_division_launched
    @data = {
      team_id: Team.first.id,
      league_id: League.first.id,
      team_invite_id: TeamInvite.first.id
    }
    @user = User.first

    mail = DivisionSeasonMailer.player_division_launched(@user.id, @data)
  end

  ######
  # RESULSTS MAILER
  ######
  def member_result_created
    @result = Result.first
    @user = User.first
    @data = {
      team_id: Team.first.id,
      league_id: League.first.id,
      fixture_id: @result.fixture.id,
      result_id: @result.id
    }
    mail = ResultMailer.member_result_created(@user.id, @data)
  end

  def member_division_result_created
    @user = FactoryGirl.create(:user)#, :as_invited)
    @team = Team.find(162072)
    @result = Result.first
    @fixture = @result.fixture
    @league = League.last

    @data = {
      team_id: @team.id,
      league_id: @league.id,
      fixture_id: @fixture.id,
      result_id: @fixture.result.id,
    }
    mail = ResultMailer.member_division_result_created(@user.id, @data)
  end
  
  def member_result_updated
    @user = User.first
    @data = {
      team_id: Team.first.id,
      league_id: League.last.id,
      fixture_id: Fixture.first.id,
      result_id: FactoryGirl.create(:soccer_result).id
    }
    mail = ResultMailer.member_result_updated(@user.id, @data)
  end

  ######
  # LEAGUE MAILER
  ######
  def league_team_message_posted
    @team = Team.first
    @message = EventMessage.create(
      :text => "A comment about the game",
      :messageable => DivisionSeason.first, 
      :user => User.last)
    @user = User.first
  
    mail = LeagueMailer.league_team_message_posted(@user, @team, @message)
  end
  
  
  def parent_league_team_message_posted
    @team = Team.first
    @message = EventMessage.create(
      :text => "A comment about the game",
      :messageable => DivisionSeason.first, 
      :user => User.last)
    @user = User.first
  
    mail = LeagueMailer.parent_league_team_message_posted(@user, @team, @message)
  end
  
  def league_organiser_role_granted_to_user

    team_invite = TeamInvite.new
    team_invite.team = Team.first
    team_invite.sent_to = User.first
    team_invite.token = "abcdef"

    team = team_invite.team
    user = team_invite.sent_to

    league = League.new
    league.title = "League"

    notification_item = NotificationItem.new
    notification_item.subj = league

    mail = LeagueMailer.organiser_role_granted_to_user(user, team_invite, notification_item)
  end

  def league_user_invited_to_team
    team_invite_token = "abcdef"

    team = Team.first
    user = User.first
    league = FactoryGirl.create(:league)

    mail = LeagueMailer.user_invited_to_team(user.id, team.id, league.id, team_invite_token)
  end

  ######
  # USER MAILER
  ######
  
  
  def event_postponed
    event = Event.first
    recipient = User.first
    organiser = User.last
    mail = UserMailer.event_postponed(event.id, recipient.id, organiser.id)
  end
  
  def event_rescheduled
    event = Event.first
    recipient = User.first
    organiser = User.last
    mail = UserMailer.event_rescheduled(event.id, recipient.id, organiser.id)
  end
  
  
  def message_posted
    t = TeamsheetEntry.new
    t.user = User.first
    t.token = "abcdef"
    t.event = Event.find(1)
    t.invite_responses << InviteResponse.new(:response_status => 1)

    m = EventMessage.new
    m.text = "This is a new message"
    m.messageable = t.event
    m.user = User.last
    m.updated_at = Time.now
    m.save!

    mail = UserMailer.message_posted(t.user, m, t)
  end

  def scheduled_event_reminder_single

    t = TeamsheetEntry.new
    t.user = User.first
    t.token = "abcdef"
    t.event = Event.find(1)
    t.invite_responses << InviteResponse.new(:response_status => 1)

    mail = UserMailer.scheduled_event_reminder_single(t)
  end

  def parent_scheduled_event_reminder_single
    junior = random(User)
    parent = random(User)

    t = TeamsheetEntry.new
    t.user = junior
    t.token = "token"
    t.event = random(Event)
    t.invite_responses << InviteResponse.new(:response_status => 1)
    t.save!

    mail = JuniorMailer.scheduled_event_reminder_single(parent.id, junior.id, t.id)
  end

  def scheduled_event_reminder_multiple

    user = User.first

    tse = (1..2).map do |i|
      t = TeamsheetEntry.new
      t.user = user
      t.token = "abcdef"
      t.event = Event.find(i)
      t.invite_responses << InviteResponse.new(:response_status => 1)
      t
    end

    mail = UserMailer.scheduled_event_reminder_multiple(user, tse)

    tse.each { |tse| tse.destroy }

    mail
  end

  def parent_scheduled_event_reminder_multiple
    junior = random(User)
    parent = random(User)

    teamsheet_entry_ids = [random(Event), random(Event)].map do |e|
      t = TeamsheetEntry.new
      t.user = junior
      t.token = "token"
      t.event = e
      t.invite_responses << InviteResponse.new(:response_status => 1)
      t.save!
      t.id
    end

    mail = JuniorMailer.scheduled_event_reminder_multiple(parent.id, junior.id, teamsheet_entry_ids, false)
  end


  def parent_scheduled_event_reminder_multiple_same_day
    junior = random(User)
    parent = random(User)

    teamsheet_entry_ids = [random(Event), random(Event)].map do |e|
      t = TeamsheetEntry.new
      t.user = junior
      t.token = "token"
      t.event = e
      t.invite_responses << InviteResponse.new(:response_status => 1)
      t.save!
      t.id
    end

    mail = JuniorMailer.scheduled_event_reminder_multiple(parent.id, junior.id, teamsheet_entry_ids, true)
  end

  def parent_event_schedule
    junior_ids = [random(User).id, random(User).id]
    parent = random(User)
    organiser = random(User)
    team = random(Team)
    event_ids = team.events.map(&:id)

    mail = JuniorMailer.event_schedule(parent.id, team.id, junior_ids, organiser.id, event_ids, 'token')
  end
  
  def parent_event_schedule_update
    junior_id = random(User).id
    parent = random(User)
    organiser = random(User)
    team = random(Team)
    event_ids = team.events.map(&:id)
    
    mail = JuniorMailer.event_schedule_update(parent.id, junior_id,  organiser.id, team.id, event_ids, 'token')
  end
  
  def parent_event_details_updated
    parent = random(User)
    junior = random(User)
    event = random(Event)
    t = TeamsheetEntry.new
    t.user = junior
    t.token = "token"
    t.event = event
    t.invite_responses << InviteResponse.new(:response_status => 1)
    t.save!
    t.id

    time = BFTimeLib.bf_format(event.time_local)
    updates = { 
      'Time' => time, 
      'Location' => event.location.title,
      'Title' => event.title
    }

    mail = JuniorMailer.event_updated(parent.id, junior.id, event.id, updates)
  end

  def parent_event_activated
    parent = random(User)
    junior = random(User)
    event = random(Event)

    mail = JuniorMailer.event_activated(parent.id, junior.id, event.id)
  end

  def parent_event_cancelled
    parent = random(User)
    junior = random(User)
    event = random(Event)
    organiser = random(User)
    
    mail = JuniorMailer.event_cancelled(parent.id, junior.id, event.id, organiser.id)
  end

  def parent_invite_reminder
    parent = random(User)
    junior = random(User)
    event = random(Event)
    
    tse = TeamsheetEntry.new
    tse.user = junior
    tse.token = "token"
    tse.event = event
    tse.invite_responses << InviteResponse.new(:response_status => 1)
    tse.save!

    invite_reminder = InviteReminder.new
    invite_reminder.teamsheet_entry = tse
    invite_reminder.user_sent_by = random(User)
    invite_reminder.save!

    mail = JuniorMailer.invite_reminder(parent.id, junior.id, invite_reminder.id)
  end

  def new_user_invited_to_team
    team_invite_token = "abcdef"

    team = Team.first
    user = User.first
    organiser = User.last

    mail = UserMailer.new_user_invited_to_team(user.id, team.id, organiser.id, team_invite_token)
  end

  def parent_invited_to_team
    parent = random(User)
    junior = random(User)
    team = random(Team)
    junior_ids = [random(User).id, random(User).id]

    mail = JuniorMailer.parent_invited_to_team(parent.id, team.id, junior_ids, team.founder.id, 'token')
  end

  def player_o2_touch_player_role_created
    event = random(Event)
    team = event.team
    user = random(User)
    role = TeamUsersService.add_player(team, user, false)

    tenant_id = 2

    data = {
      team_id: team.id,
      event_id: event.id
    }

    mail = TeamRoleMailer.player_o2_touch_player_role_created(user.id, tenant_id, data)
  end

  def organiser_o2_touch_player_role_created
    event = random(Event)
    team = event.team
    user = random(User)
    player = random(User)
    role = TeamUsersService.add_player(team, player, false)

    tenant_id = 2

    data = {
      team_id: team.id,
      event_id: event.id,
      player_id: role.user.id
    }

    mail = TeamRoleMailer.organiser_o2_touch_player_role_created(user.id, tenant_id, data)
  end

  def o2_touch_player_imported
    team = Team.where(tenant_id: 2).last
    team.divisions = []
    user = random(User)
    tenant = LandLord.o2_touch_tenant

    data = { team_id: team.id }

    mail = O2TouchMailer.player_imported(user.id, tenant.id, data)
  end

  def o2_touch_organiser_imported
    team = Team.where(tenant_id: 2).last
    team.divisions = []
    user = random(User)
    tenant = LandLord.o2_touch_tenant

    data = { team_id: team.id }

    mail = O2TouchMailer.organiser_imported(user.id, tenant.id, data)
  end

private

  def random(model)
    model.offset(rand(model.count)).first
  end
end