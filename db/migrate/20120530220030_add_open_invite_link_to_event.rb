class AddOpenInviteLinkToEvent < ActiveRecord::Migration
  def change
    add_column :events, :open_invite_link, :string
  end
end
