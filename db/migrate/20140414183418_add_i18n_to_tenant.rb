class AddI18nToTenant < ActiveRecord::Migration
  def change
  	add_column :tenants, :i18n, :string
  end
end
