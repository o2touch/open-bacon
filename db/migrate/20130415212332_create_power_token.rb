class CreatePowerToken < ActiveRecord::Migration
  def change
  	create_table :power_tokens do |t|
  		t.string :token
  		t.string :route
  		t.timestamp :expires_at
  		t.boolean :disabled, default: false
  		t.timestamps
  	end
  end
end
