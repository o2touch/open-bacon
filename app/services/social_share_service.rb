class String
	def hashtag
		"%23" + self.gsub(/\s/, '')
	end
end

class SocialShareService
	class << self

		def club_tweet_link(club)
			return nil if club.nil?
			if club.marketing && club.marketing.twitter
				text = "Get the latest #{club.marketing.twitter} %23fixtures and %23results via @mitoo_sports"
			else
				text = "Get the latest #{club.name.hashtag} %23fixtures and %23results via @mitoo_sports"
			end
			url = "http://mitoo.co/clubs/#{club.slug}?utm_source=club_share%26utm_medium=twitter%26utm_campaign=sharing"

			possible_hashtags = %w(grassroots football)
			possible_hashtags << club.name.hashtag

			# tweet size, link size, space for RT, text
			size_remaining = 140 - 22 - 16 - text.length

			hashtags_to_use = []
			possible_hashtags.each do |ht|
				if size_remaining - hashtags_to_use.join(' ').length - (ht.length + 1) > 0
					hashtags_to_use << ht
				end
			end

			twitter_url = "http://twitter.com/share"
			return "#{twitter_url}?text=#{text}&url=#{url}&hashtags=#{hashtags_to_use.join(',')}"
		end

		def team_tweet_link(team, url)
			return nil if team.nil? || url.blank?

			text = "Follow #{team.name.hashtag} on @mitoo_sports for %23fixtures and %23results"
			if team && team.club && team.club.marketing && team.club.marketing.twitter
				text += " #{team.club.marketing.twitter}"
			end
				
			# strip off any other options and add utm shit
			url = "#{url.split('?')[0]}?utm_source=team_share%26utm_medium=twitter%26utm_campaign=sharing"

			possible_hashtags = %w(grassroots football)
			possible_hashtags << team.club.name.hashtag if team && team.club

			# tweet size, link size, space for RT, text
			size_remaining = 140 - 22 - 16 - text.length

			hashtags_to_use = []
			possible_hashtags.each do |ht|
				if size_remaining - hashtags_to_use.join(' ').length - (ht.length + 1) > 0
					hashtags_to_use << ht
				end
			end

			twitter_url = "http://twitter.com/share"
			return "#{twitter_url}?text=#{text}&url=#{url}&hashtags=#{hashtags_to_use.join(',')}"
		end

		def team_stats_tweet_link(team, position, played, won, form, url)
			return nil if team.nil? || position.blank? || form.blank? || url.blank?

			text = "#{team.name.hashtag} - Position: #{position.ordinalize}, Played #{played}, Won: #{won}, Form: #{form} via @mitoo_sports."
			if team && team.club && team.club.marketing && team.club.marketing.twitter
				text += " #{team.club.marketing.twitter}"
			end

			url = "#{url.split('?')[0]}?utm_source=team_stats_share%26utm_medium=twitter%26utm_campaign=sharing"

			possible_hashtags = %w(grassroots football)
			possible_hashtags << team.club.name.hashtag if team && team.club
			possible_hashtags << "results"

			# tweet size, link size, space for RT, text
			size_remaining = 140 - 22 - 16 - text.length

			hashtags_to_use = []
			possible_hashtags.each do |ht|
				if size_remaining - hashtags_to_use.join(' ').length - (ht.length + 1) > 0
					hashtags_to_use << ht
				end
			end

			twitter_url = "http://twitter.com/share"
			return "#{twitter_url}?text=#{text}&url=#{url}&hashtags=#{hashtags_to_use.join(',')}"
		end

		def division_tweet_link(division, url)
			return nil if division.nil? || url.blank?

			division_title_str = division.league.nil? ? division.title.hashtag : division.league.title.hashtag

			text = "Check out #{division_title_str} on @mitoo_sports for %23Fixtures %23Results and %23Standings"
				
			# strip off any other options and add utm shit
			url = "#{url.split('?')[0]}?utm_source=division_share%26utm_medium=twitter%26utm_campaign=sharing"

			possible_hashtags = %w(grassroots football)

			# tweet size, link size, space for RT, text
			size_remaining = 140 - 22 - 16 - text.length

			hashtags_to_use = []
			possible_hashtags.each do |ht|
				if size_remaining - hashtags_to_use.join(' ').length - (ht.length + 1) > 0
					hashtags_to_use << ht
				end
			end

			twitter_url = "http://twitter.com/share"
			return "#{twitter_url}?text=#{text}&url=#{url}&hashtags=#{hashtags_to_use.join(',')}"
		end
	end
end