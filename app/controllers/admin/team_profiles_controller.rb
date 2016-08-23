class Admin::TeamProfilesController < Admin::AdminController

  # PUT /admin/team_profile/1
  # PUT /admin/team_profile/1.json
  def update
    @team_profile = TeamProfile.find(params[:id])
    @team = @team_profile.team

    respond_to do |format|
      if @team_profile.update_attributes(params[:team_profile])
        format.html { redirect_to @team, notice: 'Team Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render controller: [:admin, :team], action: "edit" }
        format.json { render json: @team_profile.errors, status: :unprocessable_entity }
      end
    end
  end
end
