class AddScoringSystemToDivision < ActiveRecord::Migration
  def change
  	add_column :divisions, :scoring_system, :string
  end
end
