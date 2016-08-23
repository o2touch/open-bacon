# ********** USE POWERTOKENS INSTEAD OF THIS! TS **********
class TeamInvite < ActiveRecord::Base
  belongs_to :sent_by, :class_name => "User"  
  belongs_to :sent_to, :class_name => "User"
  belongs_to :team
  
  attr_accessible :accepted_at, :sent_by, :sent_by_id, :sent_to, :sent_to_id, :source, :team_id
  
  before_create :generate_token

  def self.get_invite(team, user, from=nil)
    ti = TeamInvite.find(:first, conditions: { team_id: team.id, sent_to_id: user.id })

    if ti.nil?
      ti = TeamInvite.new
      ti.sent_to = user
      ti.team = team
      ti.sent_by = from.nil? ? team.founder : from      
      ti.generate_token
      ti.save!
    end
    
    ti
  end

  def generate_token
    self.token = SecureRandom.uuid
  end
  
  # separate incase we alter the way this happens
  def refresh_token
    self.generate_token
  end

  # old shit. TS
  def confirmed
    !self.accepted_at.nil?
  end
end
