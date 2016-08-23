class AddCreatedByIdToInviteResponse < ActiveRecord::Migration
  def change
    add_column :invite_responses, :created_by_id, :integer
  end
end
