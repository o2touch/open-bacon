module StandingsHelper

	# take hash containing ints as strings, and make them ints
	def hash_values_to_ints(points)
		return nil if points.nil?

		points.each do |k, v|
			next if v.is_a? Numeric
			return nil if v != v.to_i.to_s
			points[k] = v.to_i
		end

		points
	end
end