require 'spec_helper'

describe Location do
	describe 'validations' do

		let(:location) { FactoryGirl.build :location, :with_coordinates }

		it 'is valid when valid' do
			location.should be_valid
		end
		it 'is invalid when title > 255 chars' do
			location.title = "longgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"
			location.should_not be_valid
		end
		it 'is invalid when address > 255 chars' do # to short?? TS
			location.address = "longgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"
			location.should_not be_valid
		end
		it 'it valid when lat and lng are blank, but address is not' do
			location.lat = nil
			location.lng = nil
			location.should be_valid
		end
		it 'is valid when address is blank, but lat and lng are not' do
			location.address = nil
			location.should be_valid
		end
		it 'is invalid when lat, lng and address are blank' do
			location.lat = nil
			location.lng = nil
			location.address = nil
			location.should_not be_valid
		end
		it 'is invalid when address and lat are blank' do
			location.address = nil
			location.lat = nil
			location.should_not be_valid
		end
		it 'is invalid when address and lng are blank' do
			location.address = nil
			location.lng = nil
			location.should_not be_valid
		end
	end

	describe "#geocode" do

		before :each do

			Geocoder::Lookup::Test.add_stub(
			  "New York, NY", [
			    {
			      'latitude'     => 40.7143528,
			      'longitude'    => -74.0059731,
			      'address'      => 'New York, NY, USA',
			      'city'				=> 'New York City',
			      'state'        => 'New York',
			      'state_code'   => 'NY',
			      'country'      => 'United States',
			      'country_code' => 'US',
			      'postal_code' => 10007
			    }
			  ]
			)

			@location = FactoryGirl.build :location, lat: nil, lng: nil
			@location.address = "New York, NY"
		end

		it "sets correct values" do

			@location.lat.should be_nil
			@location.lng.should be_nil
			@location.city.should be_nil
			@location.state.should be_nil
			@location.postal_code.should be_nil
			@location.country.should be_nil

			@location.geocode

			@location.lat.should == 40.7143528
			@location.lng.should == -74.0059731
			@location.city.should == 'New York City'
			@location.state.should == 'New York'
			@location.postal_code.should == 10007
			@location.country.should == "US"
		end

	end

	describe "#reverse_geocode" do

		let(:location) { FactoryGirl.build :location, lat: 40.7143528, lng: -74.0059731 }

		it "sets correct values" do

			location.lat.should == 40.7143528
			location.lng.should == -74.0059731
			location.city.should be_nil
			location.state.should be_nil
			location.postal_code.should be_nil
			location.country.should be_nil

			location.reverse_geocode

			location.address.should == 'New York, NY, USA'
			location.city.should == 'New York City'
			location.state.should == 'New York'
			location.postal_code.should == 10007
			location.country.should == "US"
		end

	end

	describe "#has_coordinates?" do

		let(:location) { FactoryGirl.build :location, lat: nil, lng: nil }

		context "when both latitude and longitude are not set" do
			it { location.has_coordinates?.should be_false}
		end

		context "when latitude is set and longitude is not set" do
			before { location.lat = 52.12345 }
			it { location.has_coordinates?.should be_false}
		end

		context "when longitude is set and latitude is not set" do
			before { location.lng = 52.12345 }
			it { location.has_coordinates?.should be_false}
		end

		context "when both longitude and latitude are set" do

			let(:location) { FactoryGirl.build :location, :with_coordinates }

			it { location.has_coordinates?.should be_true}
		end
	end

	describe "#has_location?" do

		let(:location) { FactoryGirl.build :location }

		context "when true" do
			it { location.has_location?.should be_true}
		end

		context "when false" do
			before { location.address = nil }
			it { location.has_location?.should be_false}
		end
	end
end