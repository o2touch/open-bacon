class AddLookupIndexesToTeamRoles < ActiveRecord::Migration
  def change
   add_index "team_roles", ["user_id", "team_id"]
   add_index "team_roles", ["user_id"]
  end
end
