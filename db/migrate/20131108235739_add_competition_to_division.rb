class AddCompetitionToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :competition, :boolean
  end
end
