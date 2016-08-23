class CreateTeamInvites < ActiveRecord::Migration
  def change
    create_table :team_invites do |t|
      t.integer :sent_by_id
      t.integer :sent_to_id
      t.integer :team_id
      t.string :source
      t.datetime :accepted_at
      t.string :token

      t.timestamps
    end
  end
end
