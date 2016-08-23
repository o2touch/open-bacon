object @teamsheet_entry

if !root_object.user.nil?
  attributes :id, :user_id, :response_status, :event_id, :checked_in, :checked_in_at
  child :user do
    extends "api/v1/users/show_reduced_tse"
  end
end