class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.date :time
      t.string :location

      t.timestamps
    end
  end
end
