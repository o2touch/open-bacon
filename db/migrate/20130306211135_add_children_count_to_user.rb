class AddChildrenCountToUser < ActiveRecord::Migration
  def self.up
		add_column :users, :children_count, :integer, :default => 0
	end

	def self.down
  	remove_column :users, :children_count
	end
end
