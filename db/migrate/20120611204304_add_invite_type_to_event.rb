class AddInviteTypeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :invite_type, :integer
  end
end
