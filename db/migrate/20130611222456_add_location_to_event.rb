class AddLocationToEvent < ActiveRecord::Migration
  def change
  	# add the foreign key
  	add_column :events, :location_id, :integer
  	# add an index as we're going to look up on that shit a lot
  	add_index :locations, :title

  	say_with_time "Moving Event addresses to Location objects..." do
  		Event.reset_column_information
  		Event.all.each do |e|
  			addr = e.attributes["location"]
  			next if addr.blank?

  			loc = Location.find_by_title(addr)
  			loc = Location.create!({title: addr, address: addr}) if loc.nil?
  			
  			e.update_attributes!({ location: loc })
  		end
  	end

  	remove_column :events, :location
  end
end
