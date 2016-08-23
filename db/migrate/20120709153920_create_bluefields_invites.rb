class CreateBluefieldsInvites < ActiveRecord::Migration
  def change
    create_table :bluefields_invites do |t|
      t.integer :sent_by_id
      t.string :sent_to_email
      t.string :source

      t.timestamps
    end
  end
end
