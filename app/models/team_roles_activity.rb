class TeamRolesActivity < ActiveRecord::Base
  
  self.table_name = "team_roles_activity"

  attr_accessible :role_id, :team_id, :user_id, :team_id, :created_at, :removed_at
  
  belongs_to :user
  belongs_to :team
  
  validates :team, :presence => true
  validates :user, :presence => true 

  def revoke
  	self.removed_at = Time.now
  	self.save
  end
end
