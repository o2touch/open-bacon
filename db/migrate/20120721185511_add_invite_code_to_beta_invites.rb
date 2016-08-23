class AddInviteCodeToBetaInvites < ActiveRecord::Migration
  def up
    add_column :bf_beta_invite_requests, :invite_code, :string
  end

  def down
    remove_column(:bf_beta_invite_requests, :invite_code) if column_exists?(:bf_beta_invite_requests, :invite_code)
  end
end