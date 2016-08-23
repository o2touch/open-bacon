class DemoService
	@reject_messages = [
		"Sorry guys, I can't make this week",
		"I can't be there but I am available next week",
		"I'm still injured. Probably about another 2 weeks until I am back"
	]
	@accept_messages = [
		"Great! See you there...",
		"Can someone give me a lift to the game?",
		"Shotgun not in goal",
		"If we need another player, let me know. I have a friend who can play."
	]
	@pepe_message = "Woop, really looking forward to the game"


	def self.add_demo_users(team)
		return false if team.nil? || team.members.count > 1
		# add the demo users to the team
    DemoUser.all.shuffle!.each do |user|
      team.add_player(user)
    end

    # Nb. This gets all members regardless of role, this is what we want as we
    #   require the user to be given a teamsheet entry to kick of the demo, but
    # ************ MUST REMOVE THE ORG FROM EVENTS IF < U13 **************
    players = team.members

    pepe = DemoUser.find_by_username 'pepe'

    team.events.each do |event|
    	# turn them all to demo events
    	event[:type] = "DemoEvent"
    	event.save!

    	# create TSEs, without all the other bullshit.
    	players.each do |player|
	    	TeamsheetEntry.create({
	    		user:  player,
	    		event: event
	    	})
	    end

	    # pepe is really looking forward to the game
	   	if !pepe.nil?
		    if pepe_tse = event.teamsheet_entries.select{ |tse| tse.user.id == pepe.id }.first
		    	TeamsheetEntriesService.set_availability(pepe_tse, AvailabilityEnum::AVAILABLE)
			    self.message(pepe_tse.id, @pepe_message)
			  end
	    end
    end
    true
	end


	# TODO: Needs tests, but leaving until we decide what the required funcationality is
	# take demo flag off the team and delete all demo events
	def self.remove_demo_users(team)
		return false if team.nil?

		demo_players = team.demo_players

		# turn the events back to normal events, and remove all activity
		team.events.each do |event|

			# remove activity only for demo players specific to this team.
			unless event.nil?		

				#Remove assoicated event objects explicitly. Demo event data related to players should be 100% removed.
				tses = event.teamsheet_entries.select { |tse| demo_players.include?(tse.user) }
				assoicated_event_objects = [
					tses,
					tses.map {|x| x.invite_responses },
					event.messages.select {|x| demo_players.include?(x.user) },
					tses.map {|x| x.reminders },
				]

				assoicated_event_objects.flatten.compact.each do |association|
					if association.respond_to? :activity_items
						association.activity_items.destroy_all 
					elsif !association.activity_item.nil?
						association.activity_item.destroy
					end
					association.destroy
				end

				event[:type] = "Event"
				event.save!
			end		
		end

		# TODO: This is probably overzealous... TS
		#team.organisers.first.activity_items.destroy_all no no no

		# remove demo_users
		demo_players.each do |demo_user|
			# remove from future events (just in case)
			#TeamUsersService.remove_player_from_team(team, demo_user)
			# now remove their team roles
			roles = PolyRole.where(user_id: demo_user.id, obj_id: team.id, obj_type: 'Team')
			roles.each{ |role| PolyRole.destroy(role.id) } 
		end
	end


	def self.generate_responses(event) 
		return false if event.nil? || event.type != "DemoEvent"

		reject_messages = @reject_messages.dup.shuffle
		accept_messages = @accept_messages.dup.shuffle
		tses = event.teamsheet_entries.select{ |tse| tse.user.type == "DemoUser" }

		tses.each do |tse|
			next if tse.user.username == "pepe" # already responded yes

			# Random.rand(x) gives a number between 0 and x-1 inclusive
			# 3/4 of team accept
			accept = Random.rand(4)
			# responses are posted 3 - 23 seconds after user response
			run_at = (Random.rand(6) + 1).seconds.from_now
			# 1/2 of people add a message
			message = Random.rand(2)

			queue = "pusher"

			response = InviteResponseEnum::AVAILABLE if accept != 0
			response = InviteResponseEnum::UNAVAILABLE if accept == 0

			self.delay(run_at: run_at, queue: queue).respond(tse.id, response)

			if (message == 1)
				text = accept_messages.pop if response == InviteResponseEnum::AVAILABLE
				text = reject_messages.pop if response == InviteResponseEnum::UNAVAILABLE
				next if text.nil?
				self.delay(run_at: run_at, queue: queue).message(tse.id, text)
			end
		end
		true
	end

	private

	# post a message to the wall of the event
	def self.message(tse_id, text)
		tse = TeamsheetEntry.find(tse_id)
		tse.event.messages.create(user: tse.user, text: text)
	end

	# respond to an event.
	def self.respond(tse_id, response)
		tse = TeamsheetEntry.find(tse_id)
		TeamsheetEntriesService.set_availability(tse, response)
		tse.send_push_notification("update")  
	end
end