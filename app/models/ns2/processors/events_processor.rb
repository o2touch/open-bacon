class Ns2::Processors::EventsProcessor < Ns2::Processors::Base
	class << self
		include EventUpdateHelper

		protected
		# I'm very willing for us to make loads of assumptions in the code below -
		#   if shit fucks up nothing will be created, it'll just wait for us to
		#   fix it, then we can tell it to process again...

		# each method is expected to return an array of notification items
		def created(app_event)
			generate_nis(app_event, "event_created")
		end

		def updated(app_event)
			generate_nis(app_event, "event_updated")
		end

		def cancelled(app_event)
			generate_nis(app_event, "event_cancelled")
		end

		def activated(app_event)
			generate_nis(app_event, "event_activated")
		end

		def postponed(app_event)
			generate_nis(app_event, "event_postponed")
		end

		def rescheduled(app_event)
			generate_nis(app_event, "event_rescheduled")
		end

		def deleted(app_event)
			# do nothing.
			[]
		end

		def voided(app_event)
			[]
		end

		def abandoned(app_event)
			[]
		end

		# Had to separate this one, as it should only go to players and parents, 
		#  not followers. TS
		def invite_reminder(app_event)
			datum = "event_invite_reminder"
			event, team, league, actor = extract_data(app_event)

			# build the meta_data
			meta_data = {}
			meta_data[:event_id] = event.id
			meta_data[:team_id] = team.id
			meta_data[:actor_id] = actor.id

			tenant = LandLord.new(team).tenant


			# create the nis
			nis = []
			team.associates.each do |m|
				next if m == actor # don't email the actor
				next if m.junior? # don't email a junior

				# Let's check the general users notifications policies
				unp = UserNotificationsPolicy.new(m, tenant)
				next unless unp.should_notify?
				next unless UserTeamNotificationPolicy.new(m, team).should_notify?(datum)

				md = meta_data.clone

				# player
				if team.has_player? m
					tse = TeamsheetEntry.find_by_event_and_user(event, m)
					next unless tse.invite_responses.empty?

					md[:tse_id] = tse.id
					nis << push_ni(app_event, m, tenant, "player_#{datum}", md) if unp.can_push?
					nis << email_ni(app_event, m, tenant, "player_#{datum}", md) if unp.can_email?

					if unp.can_sms? && !unp.can_push?
						sms_sent = SmsSent.generate(m, tse, app_event)
						md[:sms_reply_code] = sms_sent.sms_reply_code
						nis << sms_ni(app_event, m, tenant, "player_#{datum}", md)
					end

				# parent
				elsif team.has_parent? m
					# needs conversion to handle multiple juniors... TS
					tse = TeamsheetEntry.find_by_event_and_user(event, m.children.first)
					next unless tse.invite_responses.empty?
					
					md[:tse_id] = tse.id
					md[:junior_id] = team.get_players_in_team(m.children.to_a).map(&:id).first
					nis << push_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.can_push?
					nis << email_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.can_email?

					if unp.can_sms? && !unp.can_push?
						sms_sent = SmsSent.generate(m, tse, app_event)
						md[:sms_reply_code] = sms_sent.sms_reply_code
						nis << sms_ni(app_event, m, tenant, "parent_#{datum}", md)
					end
				end
			end

			nis
		end

		private

		# TODO: refactor! This has become a monstrosity. Also, above is the same, innit.
		# TODO: This will not notify an org that isn't a player!
		# helper methods and shit, here
		def generate_nis(app_event, datum)
			# should we delete this?? TS
			return [] if app_event.meta_data.has_key?(:notify) && app_event.meta_data[:notify] == false

			# ***** HACK FOR VOLITUDE
			return [] if app_event.meta_data[:league_id] == 4

			event, team, league, actor = extract_data(app_event)

			# only send notifications for events 7 days from now (plus half an hour's grace)
			# quickly HACKed as hotfix... needs refactor. TS
			time = nil
			if event.status == EventStatusEnum::RESCHEDULED && app_event.meta_data.has_key?(:diff) && app_event.meta_data[:diff].has_key?(:time)
				time = app_event.meta_data[:diff][:time][0] 
			end
			time = event.time if time.nil?
			# !time.nil? for if the faft fixture is TBC
			return [] unless !time.nil? && time < 7.days.from_now && time > 1.hour.ago

			# build the meta_data
			meta_data = {}
			meta_data[:event_id] = event.id
			meta_data[:team_id] = team.id
			meta_data[:actor_id] = actor.id unless actor.nil? 
			meta_data[:league_id] = league.id unless league.nil?
			if app_event.meta_data.has_key? :diff
				meta_data[:updates] = pretty_event_atributes(app_event.meta_data[:diff]) 
			end

			tenant = LandLord.new(team).tenant

			# create the nis
			nis = []
			team.associates.each do |m|
				next if m == actor # don't email the actor

				# TODO: Move this check into UserNotificationsPolicy
				next if m.junior? # don't email a junior

				# Let's check the general users notifications policy
				unp = UserNotificationsPolicy.new(m, tenant)
				next unless unp.should_notify?

				# Let's check the user notifications policy for this team
				next unless UserTeamNotificationPolicy.new(m, team).should_notify?(datum)

				#prefs = m.get_comms_prefs
				md = meta_data.clone

				# organiser
				if team.has_organiser? m
					# we're not currently notifying orgs, prob change this? TS
				# player
				elsif team.has_player? m
					nis << push_ni(app_event, m, tenant, "player_#{datum}", md) if unp.should_push?
					nis << email_ni(app_event, m, tenant, "player_#{datum}", md) if unp.should_email?
					nis << sms_ni(app_event, m, tenant, "player_#{datum}", md) if unp.should_sms?
				# parent
				elsif team.has_parent? m
					# needs conversion to handle multiple juniors... TS
					#md[:junior_ids] = team.get_players_in_team(m.children.to_a).map(&:id)
					md[:junior_id] = team.get_players_in_team(m.children.to_a).map(&:id).first
					nis << push_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_push?
					nis << email_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_email?
					nis << sms_ni(app_event, m, tenant, "parent_#{datum}", md) if unp.should_sms?
				# follower
				else 
					nis << push_ni(app_event, m, tenant, "follower_#{datum}", md) if unp.should_push?
					nis << email_ni(app_event, m, tenant, "follower_#{datum}", md) if unp.should_email?
					nis << sms_ni(app_event, m, tenant, "follower_#{datum}", md) if unp.should_sms?
				end
			end

			nis
		end

		def extract_data(app_event)
			event = app_event.obj
			team = event.team
			league = app_event.subj.is_a?(League) ? app_event.subj : nil
			organiser = app_event.subj.is_a?(User) ? app_event.subj : nil

			return event, team, league, organiser
		end
	end
end