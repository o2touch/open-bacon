class CreateInviteResponses < ActiveRecord::Migration
  def change
    create_table :invite_responses do |t|
      t.integer :teamsheet_entry_id
      t.integer :response_status

      t.timestamps
    end
  end
end
