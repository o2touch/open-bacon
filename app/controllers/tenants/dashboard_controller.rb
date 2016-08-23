class Tenants::DashboardController < ApplicationController
	def show
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"
    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!!"

    Rails.logger.warn("current_user....")
    Rails.logger.warn(current_user.to_yaml)
    # tenant info
    @tenant = LandLord.new(params[:tenant_name]).tenant
    authorize! :read_dashboard, @tenant

    Rails.logger.warn "HIHIHIHIHIHIHIHHII I'MMMM HEREREE!!!!!! AGAINNNNNNNN"


    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "club" }).html_safe 

    @user_json = {}.to_json
    if !current_user.nil?
      @user_json = Rails.cache.fetch "#{current_user.rabl_cache_key}" do
        Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end

    @current_user_teams_json = [].to_json
    if !current_user.nil?
      @current_user_teams_json = Rails.cache.fetch "#{current_user.rabl_cache_key}/CurrentTeams" do
        Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end
    end
    
    @current_user_leagues_json = [].to_json
    if !current_user.nil?
      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end

    render :layout => 'tenant_app'
	end

  def show_teams
    # tenant info
    @tenant = LandLord.new(params[:tenant_name]).tenant
    authorize! :read_dashboard, @tenant

    @teams = Team.where(:tenant_id => @tenant.id)
    
    render :layout => 'tenant_app'
  end
end