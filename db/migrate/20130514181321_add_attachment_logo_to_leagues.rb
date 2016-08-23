class AddAttachmentLogoToLeagues < ActiveRecord::Migration
  def self.up
    change_table :leagues do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :leagues, :logo
  end
end
