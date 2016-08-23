module ShareContentHelper

	@@new_line_code = "%0D%0A%0D%0A"
	@@default_bcc_email = "andrew.c@mitoo.co"

	#####
	# Division
	#####
	def division_email_content(division)
		utm_source = utm_source({
			source: "division_share",
			medium: "email",
			campaign: "sharing_widget_v1"
      })
   division_url = default_division_url(division) + "?" + utm_source

   division_title_str = division.league.nil? ? division.title : division.league.title + " " + division.title

   email_body = "Hi Team, #{@@new_line_code}"
   email_body += "Check out the #{division_title_str} page I found on Mitoo: #{division_url}#{@@new_line_code}"
   email_body += "If you follow they update all game info automatically so you can get updates to Fixtures Games, Results and Standings via email or on your iPhone or Android phone. All looks really good, and is free for teams.#{@@new_line_code}"
   email_body += "#{division_url}#{@@new_line_code}"
   email_body += "Cheers,"

   hash = {
     button_copy: "Email Your Teammates",
     mailto:  division.title.gsub(/\s/,'_').upcase + "@MAILING_LIST_ADDRESS_HERE.COM",
     bcc: @@default_bcc_email,
     subject: division.title + " on Mitoo",
     body: email_body
   }
 end

	# This is not a Division Model
	def division_facebook_content(division)
		utm_source = utm_source({
			source: "division_share",
			medium: "facebook",
			campaign: "sharing_widget_v1"
      })

		division_url = default_division_url(division) + "?" + utm_source
		division_title_str = division.league.nil? ? division.title : division.league.title + " " + division.title

		hash = {
     url: division_url,
     title:  "Check out #{division_title_str} on Mitoo.",
     summary: "Check out #{division_title_str} on Mitoo. If you follow they update all game info automatically so you can get updates via email or on your iPhone or Android phone. #Fixtures #Results #Grassroots #Football"
     # pic: asset_path("search/bf_in_circle_black.png")
   }
 end

 	def division_twitter_url(division, url)
	  @tweet_url = SocialShareService.division_tweet_link(division, url)
	  @tweet_url.html_safe
	end


	#####
	# Team
	#####
	def team_email_content(team, division)

		utm_source = utm_source({
			source: "team_share",
			medium: "email",
			campaign: "sharing_widget_v1"
      })
    
    team_url = default_team_url(team) + "?" + utm_source

    division_title_str = ""
    unless division.nil?
      division_title_str = division.league.nil? ? division.title : division.league.title + " " + division.title
    end

    email_body = "Hi Team, #{@@new_line_code}"
    email_body += "Check out the #{team.name} page I found on Mitoo: #{team_url}#{@@new_line_code}"
    email_body += "If you follow they update all game info automatically so you can get updates to Fixtures Games, Results and Standings via email or on your iPhone or Android phone."

    email_body += "All looks really good, and is free for teams"
    email_body +=  " in #{division_title_str}" unless division.nil?
    email_body += "#{@@new_line_code}"

    email_body += "#{default_team_url(team)}#{@@new_line_code}"
    email_body += "Cheers,"
    
    hash = {
      button_copy: "Email Your Teammates",
      mailto:  team.name.gsub(/\s/,'_').upcase + "@MAILING_LIST_ADDRESS_HERE.COM",
      bcc: @@default_bcc_email,
      subject: team.name + " on Mitoo",
      body: email_body
    }
  end

  def team_facebook_content(team, division)
    team_profile_pic_url = ""
    team_profile_pic_url = team.profile.profile_picture_large_original_ratio_url unless team.profile.profile_picture_large_original_ratio_url.nil?

    hash = {
      url: default_team_url(team) + "?utm_source=[team_share]_share%26utm_medium=facebook%26utm_campaign=sharing",
      title:  "Check out #{team.name} on Mitoo.",
      summary: "Check out #{team.name} on Mitoo. If you follow they update all game info automatically so you can get updates via email or on your iPhone or Android phone. #Fixtures #Results #Grassroots #Football",
      pic: team_profile_pic_url
    }
  end

  def team_twitter_url(team, url)
    @tweet_url = SocialShareService.team_tweet_link(team, url)
    @tweet_url.html_safe
  end

	#####
	# Clubs
	#####
	def club_email_content(club)

		utm_values = "utm_source=club_share%26utm_medium=email%26utm_campaign=clubs"
		club_url = club_url(club) + "?" + utm_values

   div_sentence = ""
   if club.teams.count > 0 && !club.teams.first.divisions.first.nil? && !club.teams.first.divisions.first.league.nil?
     div_sentence = ", and is free for clubs with teams in #{club.teams.first.divisions.first.league.title}"
   end

   email_body = "Hi Guys,#{@@new_line_code}" 
   email_body += "Check out the #{club.name} page I found on Mitoo: #{club_url} #{@@new_line_code}"
   email_body += "Follow your team and install the app, and we'll all get automatic push notifications about changes to our fixtures/latest results/etc. All looks really good."
   email_body += "#{div_sentence}#{@@new_line_code}"
   email_body += "#{club_url}#{@@new_line_code}"
   email_body += "Cheers,"

   hash = {
     button_copy: "Email Your Clubmates",
     mailto:  club.name.gsub(/\s/,'_').upcase + "@MAILING_LIST_ADDRESS_HERE.COM",
     bcc: @@default_bcc_email,
     subject: club.name + " on Mitoo",
     body: email_body
   }
 end

 def club_facebook_content(club)
  utm_values = "utm_source=[club_share]_share%26utm_medium=facebook%26utm_campaign=sharing"
  club_url = club_url(club) + "?" + utm_values

  hash = {
   url: club_url,
   title: "Check out #{club.name} on Mitoo",
   summary: "Check out #{club.name} on Mitoo. They update all game info automatically so you can follow to get updates via email or on your iPhone or Android phone. #Fixtures #Results #Grassroots #Football",
   pic: asset_path(club.profile.profile_picture_large_original_ratio_url)
 }
end

def club_twitter_url(club, url)
  @tweet_url = SocialShareService.club_tweet_link(club)
  @tweet_url.html_safe
end

def utm_source(options_hash)
  return "utm_source=#{options_hash[:source]}&utm_medium=#{options_hash[:medium]}&utm_campaign=#{options_hash[:campaign]}"
end

end