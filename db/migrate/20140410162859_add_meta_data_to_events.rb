class AddMetaDataToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :tenanted_attrs, :text
  end
end
