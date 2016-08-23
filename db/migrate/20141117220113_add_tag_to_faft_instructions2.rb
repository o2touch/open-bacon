class AddTagToFaftInstructions2 < ActiveRecord::Migration
  def change
    add_column :faft_instructions_2, :tag, :string
  end
end
