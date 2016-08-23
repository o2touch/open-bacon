class DemoUser < User

	# This is very un-MVC, but the alternative is to pass the current user around
	#   fucking everywhere that *might* be overiden by a DemoXXX subclass so they
	#   can do their magic...
	#   It is set by a before filter in the top level ActionController
	def self.current_user
		Thread.current[:current_user]
	end

	def self.current_user=(user)
		Thread.current[:current_user] = user
	end


	def friends
		self.teammates
	end

	# show demo users, plus current_user
	def teammates
		return DemoUser.includes(:profile).all
	end

	def events
		return DemoTeam.first.events
	end

	# show demo users, plus current_user's first team as organiser
	def teams
		return [DemoTeam.first]
	end

	# Should not send invite reminders to demo users
	def should_send_email?
	  false
	end

  def should_send_push_notifications?
    false
  end

  def should_never_notify?
    true
  end
end
