######
# This is for one off shit for O2 Touch. (eg. importing players etc.)
#  so that we don't fill the normal processors with shit.
#  TS.
###
class Ns2::Processors::O2TouchProcessor < Ns2::Processors::Base
	class << self
		protected

		def player_imported(app_event)
			member_imported(app_event, "player_imported")
		end

		def organiser_imported(app_event)
			member_imported(app_event, "organiser_imported")
		end

		def member_imported(app_event, datum)
			nis = []

			user = app_event.subj
			team = app_event.obj
			meta_data = {
				mailer: "O2TouchMailer",
				team_id: team.id
			}

			tenant = LandLord.o2_touch_tenant
			unp = UserNotificationsPolicy.new(user, tenant)

			nis << email_ni(app_event, user, tenant, datum, meta_data) if unp.can_email?

			nis
		end
	end
end