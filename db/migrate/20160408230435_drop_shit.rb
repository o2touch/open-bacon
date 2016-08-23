class DropShit < ActiveRecord::Migration
  def up
    drop_table :league_import_data
    drop_table :api_applicants
    drop_table :beta_users
    drop_table :bf_beta_invite_requests
    drop_table :bluefields_invites
  end
end
