class Location < ActiveRecord::Base
	attr_accessible :title, :address, :lat, :lng, :city, :state, :postal_code, :country

	validates :title, length: { maximum: 255 }
	validates :address, length: { maximum: 255 }
	validate :address_or_lat_lng

	# The following uses the geocoder gem (https://github.com/alexreisner/geocoder)
	# to perform geocoding of the :address and reverse geocoding of the :lat, :lng if set
  geocoded_by :address do |obj,results|
		if geo = results.first
			obj.lat = geo.latitude
			obj.lng = geo.longitude
			# This is a good point to set the individual address components
	    obj.set_address_components_from_result(obj, geo)
	  end
  end
	reverse_geocoded_by :lat, :lng do |obj,results|
	  if geo = results.first
	  	obj.address = geo.address
	  	# This is a good point to set the individual address components
	    obj.set_address_components_from_result(obj, geo)
	  end
	end
	after_validation :reverse_geocode, :if => :has_coordinates?
  after_validation :geocode, :if => lambda{ |obj| obj.address_changed? && obj.has_location? }, :unless => :has_coordinates?

  def set_address_components_from_result(obj, geo)
  	obj.city    = geo.city
    obj.state		= geo.state
    obj.postal_code = geo.postal_code
    obj.country = geo.country_code

    # Small hack for UK addresses returned by google
    obj.state   = geo.sub_state if geo.state.blank?
  end

  # reverse gecoding is only performed when both :lat and :lng are set
  def has_coordinates?
  	!lat.blank? && !lng.blank?
  end

  # gecoding is only performed from :address
  def has_location?
  	!address.blank?
  end

	def address_or_lat_lng
		if address.blank? && (lat.blank? || lng.blank?)
			errors[:base] << "Either address or lat and lng must not be blank"
		end
	end
end	