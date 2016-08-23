class AddCompetitionToFixture < ActiveRecord::Migration
  def change
    add_column :fixtures, :competition, :boolean
  end
end
