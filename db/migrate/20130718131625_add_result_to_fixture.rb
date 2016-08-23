class AddResultToFixture < ActiveRecord::Migration
  def change
  	add_column :fixtures, :result_id, :integer
  end
end
