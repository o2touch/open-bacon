class Api::V1::Users::UserProfilesController < Api::V1::ApplicationController
	include LocationHelper

	skip_authorization_check only: [:index, :create, :destroy]
	skip_before_filter :authenticate_user!, only: [:index, :show]

	def index
		template = "api/v1/users/index_micro"

		if params.has_key? :team_id
			team = Team.find(params[:team_id])

			@users = team.associates if can? :read, team
			@users = team.followers unless can? :read, team

			template = "api/v1/users/index_reduced" if can? :manage, team

		elsif params.has_key? :division_season_id
			div = DivisionSeason.find(params[:division_season_id])

			authorize! :manage, div

			@users = div.teams.map(&:members).flatten.uniq
		else
			user = User.find(params[:user_id]) if params.has_key? :user_id
			user = current_user unless params.has_key? :user_id

			authorize! :read, user
			@users = user.friends
		end

		render template: template, formats: [:json], handlers: [:rabl], status: :ok
	end

	def show
		@user = User.find(params[:id])
		authorize! :read, @user

		template = "api/v1/users/show_reduced" if can? :read_private_details, @user
		template ||= "api/v1/users/show_micro"

		render template: template, formats: [:json], handlers: [:rabl], status: :ok
	end

	def create
		# if you implement, take out of skip_authorization_check
		head :not_implemented
	end

	def update


		@user = User.find(params[:id])
		@user.create_profile_if_not_exist # TODO: remove once everyone ahs a profile. TS.

		authorize! :update, @user

		# save some typing
		ups = params[:user]

		new_attrs = {}
		new_profile_attrs = {}

		ActiveRecord::Base.transaction do
			#Invited users can only change user roles via this action. 
			if @user.is_registered? && current_user.id == @user.id
				new_attrs[:stated_faft_team_role] = ups[:stated_faft_team_role] if ups[:stated_faft_team_role]
				new_attrs[:username] = ups[:username] if ups[:username]
				new_attrs[:time_zone] = ups[:time_zone] if ups[:time_zone]
				new_attrs[:password] = ups[:password]
				new_attrs[:password_confirmation] = ups[:password]

				new_profile_attrs[:gender] = ups[:gender] if ups[:gender]
				new_profile_attrs[:dob] = ups[:dob] if ups[:dob]
				new_profile_attrs[:bio] = ups[:bio] if ups[:bio]

				loc = process_location_json(ups[:location])
				@user.profile.location_id = loc.id unless loc.nil?

				# This is a hack. Should really be in User model - PR
				@user.clear_generated_password unless new_attrs[:password].nil?
			end

			#Allow organisers to change users contact info if they are not registered
			if @user.is_registered? || (!@user.is_registered? && current_user.id != @user.id) 
				new_attrs[:name] = ups[:name] if ups[:name]
				new_attrs[:email] = ups[:email] if ups[:email]
				new_attrs[:mobile_number] = ups[:mobile_number] if ups[:mobile_number]
			end

			if new_profile_attrs.count > 0
				@user.profile.update_attributes! new_profile_attrs
			end

			if new_attrs.count > 0 
				@user.update_attributes! new_attrs

				# tenanted attrs. #refactorthisaction
				ups[:tenanted_attrs] ||= {}
				@user.tenanted_attrs ||= {}
				ups[:tenanted_attrs].each do |k, v|
					@user.tenanted_attrs[k.to_sym] = v
				end
				@user.save!

				sign_in(@user, :bypass => true) if current_user.id == @user.id
			end
	    
	    #You can only update your own team roles from this action!
	    if !ups[:team_role_changes].nil? && current_user.id == @user.id
		    ups[:team_role_changes].each do |team_id, role|
		    	team = Team.find(team_id)
		    	TeamUsersService.migrate_user_to_role(@user, team, role)
		    end
		  end
	  end #End Transaction

    render "api/v1/users/show", formats: [:json], handlers: [:rabl], status: :ok
	end

	def destroy
		# if you implement, take out of skip_authorization_check
		head :not_implemented
	end

end