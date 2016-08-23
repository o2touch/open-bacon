class RemoveDeviseInvitableSetup < ActiveRecord::Migration
  def up
    remove_column(:users, :invitation_token) if column_exists?(:users, :invitation_token)
    remove_column(:users, :invitation_sent_at) if column_exists?(:users, :invitation_sent_at) 
    remove_column(:users, :invitation_accepted_at) if column_exists?(:users, :invitation_accepted_at) 
    remove_column(:users, :invitation_limit) if column_exists?(:users, :invitation_limit) 
    remove_column(:users, :invited_by_type) if column_exists?(:users, :invited_by_type)     
    
    if column_exists?(:users, :invited_by_id) && !column_exists?(:users, :invited_by_source_user_id) 
      rename_column(:users, :invited_by_id, :invited_by_source_user_id)
    end
  end

  def down
    add_column(:users, :invitation_token, :string, { :limit => 60 }) unless column_exists?(:users, :invitation_token) 
    add_column(:users, :invitation_sent_at, :datetime) unless column_exists?(:users, :invitation_sent_at) 
    add_column(:users, :invitation_accepted_at, :datetime) unless column_exists?(:users, :invitation_accepted_at) 
    add_column(:users, :invitation_limit, :integer) unless column_exists?(:users, :invitation_limit) 
    add_column(:users, :invited_by_id, :integer) unless column_exists?(:users, :invited_by_id) 
    add_column(:users, :invited_by_type, :string) unless column_exists?(:users, :invited_by_type)
  end
end
