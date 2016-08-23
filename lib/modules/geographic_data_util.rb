class GeographicDataUtil 
	attr_accessor :data
	
	# TODO PR - Add information around the source of this data
	DEFAULT_DATA_FILE = "#{Rails.root}/db/GeoIP.dat"
	DEFAULT_COUNTRY_CODE = "US"
	UNKNOWN =  "--"

	def initialize(args={})
		if not args[:geographic_data_hash].blank?
			@data = args[:geographic_data_hash] 
		elsif not args[:geographic_data_file].blank? 
			@data = GeoIP.new(args[:geographic_data_file])
		else
			@data = GeoIP.new(DEFAULT_DATA_FILE)
		end
	end

	def country_from_ip(ip_address)
		country = @data.country(ip_address).country_code2
		if country == UNKNOWN || ip_address == IPEnum::LOCALHOST
			return DEFAULT_COUNTRY_CODE
		end
		return country
	end
end