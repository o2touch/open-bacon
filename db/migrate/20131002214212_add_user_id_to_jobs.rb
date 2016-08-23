class AddUserIdToJobs < ActiveRecord::Migration
  def change
  	add_column :faft_instructions, :user_id, :integer
  	add_index :faft_instructions, :user_id
  	add_index :faft_instructions, :status
  end
end
