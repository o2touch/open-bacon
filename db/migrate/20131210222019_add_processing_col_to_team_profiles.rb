class AddProcessingColToTeamProfiles < ActiveRecord::Migration
  def change
  	add_column :team_profiles, :profile_picture_processing, :boolean
  end
end
