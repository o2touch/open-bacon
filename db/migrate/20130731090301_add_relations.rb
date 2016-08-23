class AddRelations < ActiveRecord::Migration
  def up
    create_table :relations do |t|
      t.string  :type
      t.integer :start_v_id
      t.string  :start_v_type
      t.integer :end_v_id
      t.string  :end_v_type
    end
  end

  def down
  end
end
