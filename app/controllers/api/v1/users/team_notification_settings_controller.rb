class Api::V1::Users::TeamNotificationSettingsController < Api::V1::ApplicationController
	skip_authorization_check only: [:create, :destroy]

	def index

		user_id = params[:id]

		raise InvalidParameter if user_id.nil?

		@user = User.find(user_id)
		# Authorized to update user
		authorize! :update, @user

		@settings_hash = {}
		@user.teams.each do |t|
			settings = UsersTeamsNotificationSetting.get_all_settings(@user, t)

			presenter = UserTeamNotificationSettingsPresenter.new(settings)
			@settings_hash[t.id] = presenter.as_hash
		end

	    render json: @settings_hash.to_json, status: :ok
	end

	def show

		user_id = params[:id]
		team_id = params[:team_id]

		raise InvalidParameter if team_id.nil? || user_id.nil?

		@user = User.find(user_id)
		# Authorized to update user
		authorize! :update, @user

		@team = Team.find(team_id)
		authorize! :read_notification_settings, @team

		settings = UsersTeamsNotificationSetting.get_all_settings(@user, @team)

		presenter = UserTeamNotificationSettingsPresenter.new(settings)
		@settings_hash = presenter.as_hash

	    render json: @settings_hash.to_json, status: :ok
	end

	def update

		user_id = params[:id]
		team_id = params[:team_id]
		settings = params[:settings]

		raise InvalidParameter if settings.nil? || team_id.nil? || user_id.nil?

		@user = User.find(user_id)
		# Authorized to update user
		authorize! :update, @user

		@team = Team.find(team_id)
		# Part of team
		authorize! :update_notification_settings, @team

		UsersTeamsNotificationSetting.add_settings(@user, @team, settings)

		settings = UsersTeamsNotificationSetting.get_all_settings(@user, @team)

		presenter = UserTeamNotificationSettingsPresenter.new(settings)
		@settings_hash = presenter.as_hash

	    render json: @settings_hash.to_json, status: :ok
	end

  def create
    # if you implement, take out of skip_authorization_check
    head :not_implemented
  end

  def destroy
    # if you implement, take out of skip_authorization_check
    head :not_implemented
  end

end