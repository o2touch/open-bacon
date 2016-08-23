class CreateUserInvitationResponse < ActiveRecord::Migration
  def self.up
    create_table :user_invitation_responses do |t|
      t.string :response
      t.integer :owner_id
      t.timestamps
    end
  end
 
  def self.down
    drop_table :user_invitation_responses
  end
end
