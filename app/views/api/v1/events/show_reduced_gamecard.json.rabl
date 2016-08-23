object @event

@user_cache_key = @user ? @user.rabl_cache_key : "NA"

cache "GameCard/#{root_object.rabl_cache_key}/#{@user_cache_key}"

permissions, tse = event_data(root_object, @user, @ability, @children)

attributes :id, :time, :time_local, :title, :created_at, :game_type
attributes :game_type_string, :status, :response_required, :time_tbc

# get the tenanted attrs
root_object.tenanted_attrs_by_tenant.each do |k, v|
  node(k) { v }
end

node :team do |event|
	{ :id => event.team_id }
end

glue :result do
	attributes :score_for, :score_against
end

node :result do
  if root_object.fixture && root_object.fixture.result
    partial("api/v1/results/show", :object => root_object.fixture.result)
  else
    partial("api/v1/event_results/show_as_result", :object => root_object.result)  
  end
end

node :permissions do
  permissions
end

node :teamsheet_entries do
  tse
end

if !root_object.location.nil?
	child :location do
		extends 'api/v1/locations/show', view_path: 'app/views'
	end
end
