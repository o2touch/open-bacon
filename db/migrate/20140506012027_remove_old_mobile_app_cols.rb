class RemoveOldMobileAppCols < ActiveRecord::Migration
  def up
  	remove_column :tenants, :mobile_app
  end
end
