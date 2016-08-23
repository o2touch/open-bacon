class Api::V1::ActivityItemLikesController < Api::V1::ApplicationController
  # skip_authorization_check only: []

  def create
    @activity_item = ActivityItem.find(params[:api_v1_activity_item_id])
    authorize! :like, @activity_item.obj

    raise InvalidParameter.new("User already likes this") and return if @activity_item.user_has_liked?(current_user)

    @activity_item_like = @activity_item.create_like(current_user)
    @activity_item_like.activity_item_id = @activity_item.id
    @activity_item_like.save!

    render template: "api/v1/activity_items/likes/show", formats: [:json], status: :ok
  end

  # uses :id param as it is glued as a member
  def destroy
    @activity_item = ActivityItem.find(params[:id])
    authorize! :like, @activity_item.obj

    @activity_item.delete_like(current_user)
    
    head :no_content
  end

end

