class AddInviteSentAtToBfBetaInviteRequests < ActiveRecord::Migration
  def up
    add_column :bf_beta_invite_requests, :invite_sent_at, :datetime
    add_column :bf_beta_invite_requests, :invite_accepted_at, :datetime
  end

  def down
    remove_column :bf_beta_invite_requests, :invite_sent_at
    remove_column :bf_beta_invite_requests, :invite_accepted_at
  end
end
