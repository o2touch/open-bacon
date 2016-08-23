object @league

attributes :id, :title, :region, :sport, :colour1, :colour2, :logo_thumb_url, :logo_small_url, :logo_medium_url, :logo_large_url, :cover_image_url, :slug

if !root_object.location.nil?
	child :location do
		extends 'api/v1/locations/show', view_path: 'app/views'
	end
end

node :divisions do |league|
	league.divisions.select.each do |div|
		partial 'api/v1/division_seasons/show_reduced', view_path: 'app/views', object: div
	end	
end
