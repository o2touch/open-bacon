class UserPreferenceController < ApplicationController  
  def show
    @team = Team.find(params[:team_id])
    @user = User.find_by_incoming_email_token!(params[:token]) #token should be the incoming_email_token for time being

    @is_follower = @team.followers.include?(@user) #Returns nil if current_user is nil
    @follow_team_role_id = @user.team_roles.where(:role_id => PolyRole::FOLLOWER).first if @is_follower
    
    if current_user.nil? && @is_follower
      sign_in @user, :bypass => true
    elsif current_user && (@user.id != current_user.id)
      #You should not be able to view the preferences of another user
      raise ActionController::RoutingError.new('Not Found') #Force 404
    end
  end
end
