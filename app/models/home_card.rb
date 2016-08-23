class HomeCard
	attr_accessor :type, :header_text, :obj_type, :obj, :data

	def to_json
		return {
			:type => type,
			:header_text => header_text,
			:obj_type => obj_type,
			:obj => nil,
			:data => nil
		}
	end
end