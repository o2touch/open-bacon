class FiveASideTeam
	def initialize(founder=nil)
    founder = FactoryGirl.create(:user) if founder.nil?
    @team = FactoryGirl.create(:team, :created_by => founder)
    
    registered_users = FactoryGirl.create_list(:user, 2)
    invited_users = FactoryGirl.create_list(:user, 2, :as_invited)
    registered_users.concat(invited_users).each { |user| TeamUsersService.add_player(@team, user, false) }

    events = TimeEnum.values.map { |time| FactoryGirl.create(:event, :user => @team.founder, :team => @team, :time => time) }
    @team.save
    @team.reload

    events.each {|x| } #SR - If you remove this tests break. TODO: Work out why!
    events.each do |event| 
      EventInvitesService.add_players(event, @team.players) 
    end
    @team.save
    @team.reload
	end

  def reload
    @team.reload
  end

	def founder
    @team.founder
	end

	def sport
    @team.profile.sport
	end

	def organisers
    @team.organisers
	end

  def organiser
    self.organisers.sample(1).first
  end

	def players 
    @team.players
  end

	def player(include_organisers=false)
    players = self.players
    players = players.find_all { |player| player != self.founder } unless include_organisers
    players.sample(1).first
	end

	def events
    @team.events
	end

	def event
    self.events.sample(1).first
	end

  def get_role(member, role_enum)
    PolyRole.find(:first, :conditions => [ "obj_type='Team' AND obj_id = ? AND user_id = ? AND role_id = ?", @team.id, member.id, role_enum ])
  end

  def member?(member)
    @team.has_member?(member)
  end

  def get_future_events_for_member(member)
    @team.future_events.find_all { |event| event.is_invited?(member) } 
  end

  def get_past_events_for_member(member)
    @team.past_events.find_all { |event| event.is_invited?(member) } 
  end
end
