module SmserHelper

	def mobile_footer_text(user, team)
		if !user.is_registered?
			team_invite = TeamInvite.get_invite(team, user)
			short_link = get_short_link("#{team_invite_link_url(:token => team_invite.token, :only_path => false )}")
			return "Confirm your account: #{short_link}"
		elsif user.mobile_devices.empty?
			short_link = get_short_link("#{app_download_url}")
			return "Download the app: #{short_link}"
		end

		""
	end

	def follower_download_prompt(user, team)
    p = ""
    p = " Download the app to get more information on your phone: #{app_download_url}" if user.mobile_devices.count == 0

    team_invite  = TeamInvite.find(:first, conditions: ["team_id = ? and sent_to_id = ? and accepted_at is not null", team.id, user.id])
    if team_invite
    	short_link = get_short_link("#{team_invite_link_url(:token => team_invite.token, :only_path => false )}")
    	p = " Confirm your account here: #{short_link}"
    end
    p
  end

	def get_short_link(link)
		return link unless Rails.env.Production?

		bitly_url = $bitly.shorten(link)
		bitly_url.short_url
	end

end