module ProfilePictureHelper

	# Profile picture helper, use
	# to make sure profile picture 
	# use correct asset path, and default
	# to generic picture if non existing.
	# 
	# NOTE: This now default to the team
	# profile picture (mainly use on 
	# club & team faft page). If using
	# for user model, the function should
	# be modified adequately
	def profile_picture_helper(model, attribute,  options={})

		# Set default image
		error_path = asset_path("profile_pic/team/generic_team_#{attribute}.png")
		path = model.profile.profile_picture(attribute)

		# If error_path and path are not the same, 
		# set a onerror tag, in case assets are fucked
		options[:onerror] = "this.src='#{error_path}';" unless path == error_path


		# Set default alt & title attribute for image
		if !model.name.nil?
			options[:alt] = "Profile picture of #{model.name}" unless !options[:alt].nil?
			options[:title] = model.name unless !options[:title].nil?
		end
		

		return image_tag(path, options)
	end


	def league_logo_helper(model, attribute,  options={})

		# Set default image
		error_path = asset_path("profile_pic/league/generic_league_#{attribute}.png")
		path = model.logo(attribute)

		# If error_path and path are not the same, 
		# set a onerror tag, in case assets are fucked
		options[:onerror] = "this.src='#{error_path}';" unless path == error_path

		# Set default alt & title attribute for image
		if !model.title.nil?
			options[:alt] = "Logo of #{model.title}" unless !options[:alt].nil?
			options[:title] = model.title unless !options[:title].nil?
		end
		

		return image_tag(path, options)
	end

end