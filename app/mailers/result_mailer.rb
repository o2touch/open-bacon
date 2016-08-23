class ResultMailer < ActionMailer::Base

  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper
  include DivisionUrlHelper
  include TeamUrlHelper
  
  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

  # RESULT CREATED
  # - As soon as a result os added to a fixture
  # - Results added by league organiser or scraper

  # Generic Result Created Template
  def member_result_created(recipient_id, tenant_id, data, render_parent=false)
    valid_data, @recipient, @tenant, @team, @league, @fixture, @result = process_result_data(recipient_id, tenant_id, data)
    return if !valid_data

    t_path = default_team_path(@team)
    @token = PowerToken.generate_token(t_path, @recipient) unless @recipient.is_registered?

    if render_parent
      valid_parent_data, @juniors = process_parent_data(data)
      return if !valid_parent_data
    end

    from, to = get_mail_from_to_data(@team, @recipient)
    subject = subject_for_result_created(@result, @team)
    mail(:from => from, :to => to, :subject => subject, :template_name => 'member_result_created')
  end

	def organiser_result_created(recipient_id, tenant_id, data)
		member_result_created(recipient_id, tenant_id, data)
	end

	def player_result_created(recipient_id, tenant_id, data)
		member_result_created(recipient_id, tenant_id, data)
	end

	def follower_result_created(recipient_id, tenant_id, data)
		member_result_created(recipient_id, tenant_id, data)
	end
	
	def parent_result_created(recipient_id, tenant_id, data)
		member_result_created(recipient_id, tenant_id, data, true)
	end
	

  # DIVISION RESULT CREATED
  # - As soon as a result os added to a fixture in same div as user
  # - Results added by league organiser or scraper

  # Generic Result Created Template
  def member_division_result_created(recipient_id, tenant_id, data, render_parent=false)
    valid_data, @recipient, @tenant_id, @team, @league, @fixture, @result = process_result_data(recipient_id, tenant_id, data)
    return if !valid_data

    @division = @fixture.division_season
    div_path = default_division_path(@division)
    @token = PowerToken.generate_token(div_path, @recipient) unless @recipient.is_registered?
    @div_url = default_division_url(@division, :only_path => false) if @recipient.is_registered?

    if render_parent
      valid_parent_data, @juniors = process_parent_data(data)
      return if !valid_parent_data
    end

    from, to = get_mail_from_to_data(@team, @recipient)
    subject = subject_for_div_result_created(@fixture)
    mail(:from => from, :to => to, :subject => subject, :template_name => 'member_division_result_created')
  end

  def organiser_division_result_created(recipient_id, tenant_id, data)
    member_division_result_created(recipient_id, tenant_id, data)
  end

  def player_division_result_created(recipient_id, tenant_id, data)
    member_division_result_created(recipient_id, tenant_id, data)
  end

  def follower_division_result_created(recipient_id, tenant_id, data)
    member_division_result_created(recipient_id, tenant_id, data)
  end
  
  def parent_division_result_created(recipient_id, tenant_id, data)
    member_division_result_created(recipient_id, tenant_id, data, true)
  end
  

	# HELPERS
	def process_result_data(recipient_id, tenant_id, data)
		recipient = User.find(recipient_id)
    tenant = Tenant.find(tenant_id)

		team = Team.find(data[:team_id]) if data.has_key? :team_id
		league = League.find(data[:league_id]) if data.has_key? :league_id
		fixture = Fixture.find(data[:fixture_id]) if data.has_key? :fixture_id
		result = Result.find(data[:result_id]) if data.has_key? :result_id
		
		return false if fixture.nil?

		return true, recipient, tenant, team, league, fixture, result
	end

  def process_parent_data(data)
    juniors = User.find(data[:junior_ids])
    return false if juniors.nil? || juniors.empty?

    return true, juniors
  end

	def get_mail_from_to_data(team, recipient)
    from = determine_team_from_address(team, recipient)
    to = format_email_to_user(recipient)

    return from, to
  end
end