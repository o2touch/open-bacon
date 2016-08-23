class ChangeInvitedByTypeOnUsersTable < ActiveRecord::Migration
  def change
    rename_column :users, :invited_by_type, :invited_by_source
  end
end
