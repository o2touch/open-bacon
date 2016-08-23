class AddBluefieldsInviteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bluefields_invite_id, :integer
  end
end
