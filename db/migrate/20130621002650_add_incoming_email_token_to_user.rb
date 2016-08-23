class AddIncomingEmailTokenToUser < ActiveRecord::Migration
  def change
  	add_column :users, :incoming_email_token, :string

  	say_with_time "Adding incoming_email_tokens to users" do
  		User.all.each do |u|
  			u.update_attributes({ incoming_email_token: SecureRandom.hex })
  		end
  	end
  end
end
 