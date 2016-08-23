class CreateUtmData < ActiveRecord::Migration
  def change
    create_table :utm_data do |t|
      t.string :referer
      t.string :source
      t.string :medium
      t.string :term
      t.string :content
      t.string :campaign
      t.integer :user_id
      t.timestamps
    end

    add_index :utm_data, :user_id
  end
end
