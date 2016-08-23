class CreateContactRequests < ActiveRecord::Migration
  def change
    create_table :contact_requests do |t|
      t.string :name
      t.string :email
      t.string :organisation
      t.integer :demo
      t.text :message
      t.string :data

      t.timestamps
    end
  end
end
