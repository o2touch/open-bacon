require 'spec_helper'

describe LocationHelper do
	describe '#process_location_json' do
		it 'returns nil if you give it nil' do
			process_location_json(nil).should be_nil
		end
		it 'looks up the location in the db if json[:id] is not nil' do
			Location.should_receive(:find).with(1)
			process_location_json({id: 1})
		end
		it 'creates a location if neither of the above are true' do 
			# in which case validations should make sure shit is all cool	
			Location.should_receive(:create!)
			process_location_json({address: "ting", lat: "1", lng: "2", title: "other ting"})
		end
	end
end