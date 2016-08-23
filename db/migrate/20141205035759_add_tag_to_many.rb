class AddTagToMany < ActiveRecord::Migration
  def change
    tables = [:leagues, :fixed_divisions, :division_seasons, :teams, :team_division_season_roles, :fixtures]
    tables.each do |t|
      add_column t, :tag, :string
    end
  end
end
