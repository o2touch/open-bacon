class AddCoverImageToLeagueModel < ActiveRecord::Migration
  def self.up
    change_table :leagues do |t|
      t.attachment :cover_image
    end
  end

  def self.down
    drop_attached_file :leagues, :cover_image
  end
end
