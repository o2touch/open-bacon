class TeamInvitePolicy

	def initialize(team)
	    @team = team
	end

	def can_invite?(user)
		(@team.profile.age_group == AgeGroupEnum::ADULT && !user.junior?) ||
		(@team.profile.age_group >= AgeGroupEnum::UNDER_14 && !user.junior?) ||
		(@team.profile.age_group <= AgeGroupEnum::UNDER_13  && user.junior?)
	end
end