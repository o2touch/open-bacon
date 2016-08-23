class AddScrapedIdToFaftInstruction < ActiveRecord::Migration
  def change
  	add_column :faft_instructions, :scraped_id, :integer
  end
end
