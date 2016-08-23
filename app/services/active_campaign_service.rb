# require 'net/http'
# require 'uri'
# require 'json'

# class ActiveCampaignService
# 	class << self
		
# 		def process_follow(team_role_id)
# 			begin
# 				team_role = PolyRole.find_by_id(team_role_id)

# 				return if team_role.nil?
# 				return unless team_role.role_id == 4
# 				return if team_role.obj.club.nil?

# 				user = team_role.user
# 				club = team_role.obj.club
# 				marketing = club.marketing

# 				if user.email == marketing.contact_email || user.name == marketing.contact_name
# 					send_event_request(marketing.contact_email, :club_contact_followed, true)
# 				else
# 					follow_count = User.find_by_sql("select distinct users.* from users, teams, team_roles 
# 																						where users.id=team_roles.user_id 
# 																						and team_roles.team_id=teams.id 
# 																						and teams.club_id=#{club.id}").count
# 					send_event_request(marketing.contact_email, :club_followed, follow_count)
# 				end
# 			rescue
# 				Rails.logger.warn "ERROR IN ActiveCampaignService.process_follow()"
# 			end
# 		end

# 		def submit_follower(user_id, club_id)
# 			user = User.find(user_id)
# 			club = Club.find(club_id)

# 			contact = {
# 				email: user.email,
# 				first_name: user.first_name,
# 				last_name: "SURNAME",
# 				"field[%F_CLUB%]" => club.name,
# 				"field[%F_CLUB_ID%]" => club.id,
# 				"field[%F_CLUB_LINK%]" => "http://mitoo.co/clubs/#{club.slug}",# Should use asset_path here
# 				"p[3]" => "3", # the club list id
# 				"status[???]" => 1
# 			}

# 			ActiveCampaign.configure do |config|
# 				config.api_key = ActiveCampaign::Config::API_KEY
# 				config.api_path = ActiveCampaign::Config::API_PATH
# 				config.api_output = ActiveCampaign::Config::API_OUTPUT
# 				config.api_endpoint = ActiveCampaign::Config::API_ENDPOINT
# 			end

# 			return unless Rails.env.production?
# 			ActiveCampaign.contact_sync(contact)
# 		end

# 		def submit_club_contact(club_id, list_id=2)
# 			club = Club.find(club_id)
# 			club.marketing.junior.downcase! unless club.marketing.junior.nil?
# 			raise "invalid strategy" unless club.marketing.strategy == "email"

# 			contact = {
# 				email: club.marketing.contact_email,
# 				first_name: club.marketing.contact_forename,
# 				last_name: club.marketing.contact_surname,
# 				"field[%CLUB%]" => club.name,
# 				"field[%CLUB_ID%]" => club.id,
# 				"field[%CLUB_LINK%]" => "http://mitoo.co/clubs/#{club.slug}",
# 				"field[%ADDRESS%]" => club.location.address,
# 				"field[%GROUND%]" => club.location.title,
# 				"field[%JUNIOR%]" => club.marketing.junior,
# 				"field[%PHONE%]" => club.marketing.contact_phone,
# 				"field[%ROLE%]" => club.marketing.contact_position,
# 				"field[%LEAGUE%]" => club.teams.first.divisions.first.league.title,
# 				"field[%CAMPAIGN%]" => club.marketing.split,
# 				"p[2]" => "2", # the club list id
# 				"status[2]" => 1
# 			}

# 			ActiveCampaign.configure do |config|
# 				config.api_key = ActiveCampaign::Config::API_KEY
# 				config.api_path = ActiveCampaign::Config::API_PATH
# 				config.api_output = ActiveCampaign::Config::API_OUTPUT
# 				config.api_endpoint = ActiveCampaign::Config::API_ENDPOINT
# 			end

# 			#return unless Rails.env.production?
# 			ActiveCampaign.contact_sync(contact)
# 		end

# 		###
# 		# Sync users to FAFT Followers List
# 		###

# 		def sync_faft_followers(users)
# 			users.each do |u|
# 				self.sync_faft_follower(u)
# 			end
# 		end

# 		def sync_faft_follower(user_obj_or_id)

# 			# Used eager loading here to reduce DB queries - PR
# 			user = User.includes(:mobile_devices, :team_roles => [:team => :players]).find(user_obj_or_id) if user_obj_or_id.is_a? Integer
# 			user = user_obj_or_id if user_obj_or_id.is_a? User

# 			team = user.teams_as_follower.first
# 			return if team.nil?
			
# 			players_invited_to_team = team.players.where(:invited_by_source_user_id => user.id).length
# 			downloaded_app_str = (user.mobile_devices.length > 0) ? 'yes' : 'no'
# 			total_team_members = team.players.length

# 			contact = {
# 				email: user.email,
# 				first_name: user.first_name,
# 				last_name: user.last_name,
# 				"field[%F_INVITED%]" => players_invited_to_team,
# 				"field[%F_TEAM_NAME%]" => team.name,
# 				"field[%F_TEAM_LINK%]" => Rails.application.routes.url_helpers.team_url(team, :only_path => false),
# 				"field[%F_TEAM_FOLLOWERS%]" => total_team_members,
# 				"field[%F_DOWNLOADED_APP%]" => downloaded_app_str,
# 				"p[3]" => "4", # the list id
# 				"status[???]" => 1
# 			}

# 			ActiveCampaign.configure do |config|
# 				config.api_key = ActiveCampaign::Config::API_KEY
# 				config.api_path = ActiveCampaign::Config::API_PATH
# 				config.api_output = ActiveCampaign::Config::API_OUTPUT
# 				config.api_endpoint = ActiveCampaign::Config::API_ENDPOINT
# 			end

# 			return unless Rails.env.production?
# 			ActiveCampaign.contact_sync(contact)
# 		end

# 		###
# 		# Process List Actions sent by AC WebHook interface
# 		###
# 		def process_list_action(params)
# 			action = params[:type]
# 			accepted_actions = %w[open click forward share bounce reply]

# 			self.send("process_#{action}", params) if accepted_actions.include? action
# 		end

# 		def process_open(params)
# 			# Could do some more stuff here
# 			# Save the event
# 			meta_data = nil
# 			create_event(params[:contact][:email], "open", params[:contact][:id], params[:campaign][:id], params[:list], params[:contact][:ip], params[:date_time], meta_data)
# 		end

# 		def process_click(params)
# 			# Could do some more stuff here
# 			# Save the event
# 			meta_data = {
# 				link: params[:link]
# 			}
# 			create_event(params[:contact][:email], "click", params[:contact][:id], params[:campaign][:id], params[:list], params[:contact][:ip], params[:date_time], meta_data)
# 		end

# 		def process_forward(params)
# 			# Could do some more stuff here
# 			# Save the event
# 			meta_data = {
# 				forward: params[:forward]
# 			}
# 			create_event(params[:contact][:email], "forward", params[:contact][:id], params[:campaign][:id], params[:list], params[:contact][:ip], params[:date_time], meta_data)
# 		end

# 		def process_share(params)
# 			# Could do some more stuff here
# 			# Save the event
# 			meta_data = {
# 				share: params[:share]
# 			}
# 			create_event(params[:contact][:email], "share", params[:contact][:id], params[:campaign][:id], params[:list], params[:contact][:ip], params[:date_time], meta_data)
# 		end

# 		def process_bounce(params)
# 			# Could do some more stuff here
# 			# Save the event
# 			meta_data = {
# 				bounce: params[:bounce]
# 			}
# 			create_event(params[:contact][:email], "bounce", params[:contact][:id], params[:campaign][:id], params[:list], params[:contact][:ip], params[:date_time], meta_data)
# 		end

# 		def process_reply(params)
# 			# Could do some more stuff here
# 			# Save the event
# 			meta_data = {
# 				ip: params[:contact][:ip],
# 				message: params[:message]
# 			}
# 			create_event(params[:contact][:email], "reply", params[:contact][:id], params[:campaign][:id], params[:list], params[:contact][:ip], params[:date_time], meta_data)
# 		end

# 		private

# 		def send_event_request(id_email, event, event_data)
# 			return false if event_data.nil? || event.nil?
# 			return unless Rails.env.production?

# 		  uri = URI.parse('https://trackcmp.net/event')

# 		  body = {
# 		  	actid: '24973710',
# 		  	key: '59d9c73ba67265e956d091d7c62083cd4d74c6d2',
# 		  	event: event,
# 		  	event_data: event_data,
# 		  	visit: {
# 		  		email: id_email
# 		  	}
# 		  }

# 		  http = Net::HTTP.new(uri.host, uri.port)
# 		  http.use_ssl = true

# 		  request = Net::HTTP::Post.new(uri.path)
# 		  request.body = body.to_query

# 		  response = http.request(request)
# 		  puts response.code
# 		  puts response.message
# 		end

# 		def create_event(email, event, contact_id, list_id, campaign_id, ip, event_time, meta_data)

# 			user = User.find_by_email(email)
# 			user_id = user.nil? ? nil : user.id

# 			e = ActiveCampaignEvent.new
# 			e.email = email
# 			e.user_id = user_id
# 			e.contact_id = contact_id
# 			e.event = event
# 			e.list_id = list_id
# 			e.campaign_id = campaign_id
# 			e.meta_data = meta_data
# 			e.event_time = event_time
# 			e.ip = ip
# 			e.save
# 		end
# 	end
# end