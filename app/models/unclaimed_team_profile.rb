# Nolonger used. Left in as there's shit loads of stuff in the table. TS
class UnclaimedTeamProfile < ActiveRecord::Base

  belongs_to :team
  belongs_to :unclaimed_league_profile
  
  has_one :unclaimed_team_profile_problem
  
  before_create :create_token, :generate_slug
  
  attr_accessible :contact_email, :contact_name, :contact_number, :league_name, :location, :name, :team_id, :sport, :slug, :source
  attr_accessible :contact_email2, :contact_name2, :contact_number2, :colour1, :colour2, :contact_title, :contact_title2
  
  def create_token
    token_length = 16      
    self.token = rand(36**token_length).to_s(36)
  end
  
  def generate_slug(name=nil)
    name = self.name if name.nil?
    self.slug = name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end
  
  def has_emailed?
    emails = ClaimProfileCampaignEmail.find_by_profile_id(self.id)
    return !emails.nil?
  end
  
  def claim
    if self.team.nil?
      team = Team.new
      team.build_profile
      team.name = self.name
      team.profile.league_name = self.league_name
      team.profile.sport = self.sport || SportEnum::OTHER
      team.profile.colour1 = self.colour1 || DefaultColourEnum::DEFAULT_1
      team.profile.colour2 = self.colour2 || DefaultColourEnum::DEFAULT_2
      team.profile.age_group = AgeGroupEnum::ADULT
      team.save!
      team.profile.save!
      
      self.team = team
      self.save!  
      team
    else
      nil
    end
  end
  
  def to_param
    
    if !self.unclaimed_league_profile.nil?
      self.unclaimed_league_profile.to_param + "/" + self.slug
    else
      self.slug
    end
  end
  
end
