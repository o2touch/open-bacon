object @event
cache "Reduced/#{root_object.rabl_cache_key}"

attributes :id, :time, :time_local, :title, :invite_type, :created_at, :availability_summary
attributes :game_type, :game_type_string, :time_of_last_reminder, :response_by, :reminder_updated
attributes :status, :has_players_invited, :organiser_message, :team_id, :time_tbc, :check_in_summary

if !root_object.team.nil?
  child :team do
    extends "teams/show"
  end
else
  node :team do
    {}
  end
end

if !root_object.result.nil?
  glue :result do
    attributes :score_for, :score_against, :set
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