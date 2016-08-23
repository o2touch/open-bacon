class Ns2::Processors::CommentsProcessor < Ns2::Processors::Base
	class << self
		protected

		def created(app_event)
			comment = app_event.obj
			datum = "comment_created"
			meta_data = {
				comment_id: comment.id,
				actor_id: app_event.subj.id,
				activity_item_id: comment.activity_item.id,
				mailer: "CommentMailer", # override normal mailer
				pusher: "CommentPusher" # override normal purhser
			}

			obj = comment.activity_item.obj
			return message_ai_comment(app_event, datum, comment, meta_data) if obj.is_a? EventMessage
			return invite_response_ai_comment(app_event, datum, comment, meta_data) if obj.is_a? InviteResponse

			# other kinds here...

			[]
		end

		private
		def message_ai_comment(app_event, datum, comment, meta_data)
			datum = "message_#{datum}"
			messageable = comment.activity_item.obj.messageable #event/div/team
			tenant = LandLord.new(messageable).tenant

			meta_data[:feed_owner_type] = messageable.class.name
			meta_data[:feed_owner_id] = messageable.id

			generate_nis(app_event, tenant, comment, meta_data, datum)
		end

		def invite_response_ai_comment(app_event, datum, comment, meta_data)
			datum = "invite_response_#{datum}"
			event = comment.activity_item.obj.teamsheet_entry.event
			tenant = LandLord.new(event).tenant

			meta_data[:feed_owner_type] = "Event"
			meta_data[:feed_owner_id] = event.id

			generate_nis(app_event, tenant, comment, meta_data, datum)
		end


		def generate_nis(app_event, tenant, comment, meta_data, datum)
			nis = []

			# figure out who we're going to email
			users = comment.activity_item.comments.map(&:user)
			users << comment.activity_item.subj if comment.activity_item.subj.is_a? User
			users.uniq!

			users.each do |u|
				next if u == app_event.subj

				unp = UserNotificationsPolicy.new(u, tenant)
				next unless unp.should_notify?

				# we don't check the team policy here they'll only receive a notification
				#  if they were previously involved in the conversation.

				nis << email_ni(app_event, u, tenant, datum, meta_data) if unp.should_email?
				nis << push_ni(app_event, u, tenant, datum, meta_data) if unp.should_push?
			end
			nis
		end
	end
end
