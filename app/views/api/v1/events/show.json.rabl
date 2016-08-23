object @event

@user_cache_key = ""
if @user
	@user_cache_key = @user.rabl_cache_key
end

cache "#{root_object.rabl_cache_key}/#{@user_cache_key}"

ability = Ability.new(@user)

attributes :id, :time, :time_local, :title, :invite_type, :created_at, :availability_summary
attributes :game_type, :game_type_string, :time_of_last_reminder, :response_by
attributes :reminder_updated, :status, :has_players_invited, :team_id, :type, :response_required
attributes :time_tbc, :updated_at, :home_or_away, :check_in_summary

# get the tenanted attrs
root_object.tenanted_attrs_by_tenant.each do |k, v|
	node(k) { v }
end

if ability.can? :send_invites, root_object
	attributes :open_invite_link
end

if !root_object.team.nil?
	child :team do
		extends "api/v1/teams/show", view_path: 'app/views'
	end
else
	node :team do
		{}
	end
end

if !root_object.cached_teamsheet_entries.nil?
	if ability.can? :view_private_details, @event
		child :teamsheet_entries do
			extends "api/v1/teamsheet_entries/show", view_path: 'app/views'
		end
	else
		child :teamsheet_entries do
			extends "api/v1/teamsheet_entries/show_private", view_path: 'app/views'
		end
	end
else
	node :teamsheet_entries do
		[]
	end
end

if !root_object.result.nil?
	glue :result do
	  attributes :score_for, :score_against, :set
	end
end

node :result do
  if root_object.fixture && root_object.fixture.result && @app_fix_reverse_result
  	# ALSO in show_reduced_gamecard_mobile.json.rabl
  	# ****HACK TO FIX RESULTS BEING WRONG WHEN TEAM IS AWAY****
    partial("api/v1/results/show_reverse", :object => root_object.fixture.result)
  elsif root_object.fixture && root_object.fixture.result
    partial("api/v1/results/show", :object => root_object.fixture.result)
  else
    partial("api/v1/event_results/show_as_result", :object => root_object.result)  
  end
end

if !root_object.user.nil?
	child :user do
		attributes :id, :name
		
		child :profile do
			attributes :profile_picture_thumb_url
		end
	end
else
	node :user do
		{}
	end
end

if !root_object.location.nil?
	child :location do
		extends 'api/v1/locations/show', view_path: 'app/views'
	end
end

node :permissions do
	permissions = Hash.new
	permissions["canManageAvailability"] = ability.can?(:manage, root_object.team)
	permissions["canEditEvent"] = ability.can? :manage_event, root_object
	permissions["canViewAllDetails"] = ability.can? :read_private_details, root_object
	permissions["canPostMessage"] = ability.can? :create_message, root_object
	permissions["canViewMessages"] = ability.can? :read_messages, root_object
	permissions["canSendInvites"] = ability.can? :send_invites, root_object
	permissions["canRespondToPrivateInvite"] = ability.can? :respond_to_invite, root_object
	permissions["canExportToCalendar"] = ability.can? :export_to_calendar, root_object
	permissions["canEdit"] = ability.can? :manage_event, root_object
	permissions["canRespond"] = root_object.cached_teamsheet_entries.any?{ |x| ability.can?(:respond, x) }
	permissions["canJoin"] = ability.can?(:join_as_player, root_object.team)
	permissions["canFollow"] = ability.can?(:follow, root_object.team)
	permissions
end
