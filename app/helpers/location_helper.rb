# shit to help process creates/updates that including a location sub-object
module LocationHelper
	def process_location_json(json)
		return nil if json.nil? || json.empty?
		return Location.find(json[:id]) unless json[:id].nil? 

		Location.create!({
      address: json[:address],
      lat: json[:lat],
      lng: json[:lng],
      title: json[:title]
		})
	end
end
