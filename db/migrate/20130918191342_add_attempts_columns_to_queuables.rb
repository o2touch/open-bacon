class AddAttemptsColumnsToQueuables < ActiveRecord::Migration
  def change
  	add_column :ns2_notification_items, :attempts, :integer
  	add_column :faft_instructions, :attempts, :integer
  end
end
