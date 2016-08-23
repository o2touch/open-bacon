object @tenant

attributes :id, :name, :subdomain, :profile_picture_url_thumb_url
attributes :profile_picture_small_url, :profile_picture_medium_url, :profile_picture_large_url

# I don't really like this, but can't think of a better way right now... TS
# (prob needs to have nest options, then iterate though the right hash. TS)
node :page_options do |t|
	# all pages e.g. for the nav / register popup
	result = {
		feedback_url: t.config.feedback_url,
		support_url: t.config.support_url,
		team_followable: t.config.team_followable == true
	}

	case @page
	when "event"
		result[:show_club_widget] = t.config.show_event_page_club_widget == true
		result[:show_goals] = t.config.show_event_page_goals == true
		result
	when "team"
		result[:show_club_widget] = t.config.show_team_page_club_widget == true
		result[:show_club_map] =  t.config.show_team_page_club_map == true
		result[:show_search] =  t.config.show_team_page_search == true
		result[:show_team_page_invite_link] =  t.config.show_team_page_invite_link == true
		result[:show_marketing_copy_widget] = t.config.show_team_page_marketing_copy_widget
		result
	# when "division"
	# when "league"
	# when "user"
	else
		result
	end
end

# i18n shit, for when we have to make copy changes
node :page_copy do |t|
	tr = I18n.t(@page, locale: root_object.i18n)
	tr.is_a?(String) ? {} : tr 
end

# i18n shit, for when we have to make copy changes
node :general_copy do |t|
	tr = I18n.t(:general, locale: root_object.i18n)
	tr.is_a?(String) ? {} : tr 
end