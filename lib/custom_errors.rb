class InviteToTeamError < StandardError 
  attr_reader :error_code, :user
  def initialize(error_code=nil, user=nil)
    @error_code = error_code
    @user = user
  end
end

class TeamRoleError < StandardError; end