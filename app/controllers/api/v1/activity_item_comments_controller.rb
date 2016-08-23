class Api::V1::ActivityItemCommentsController < Api::V1::ApplicationController
	skip_authorization_check only: [:index, :show, :update, :destroy]

  def create
    @activity_item = ActivityItem.find(params[:api_v1_activity_item_id])
    authorize! :comment, @activity_item.obj

    @activity_item_comment = @activity_item.create_comment(current_user, params[:activity_item_comment][:text])

    meta_data = { processor: "Ns2::Processors::CommentsProcessor" }
    AppEventService.create(@activity_item_comment, current_user, "created", meta_data)
    
    render template: "api/v1/activity_items/comments/show", formats: [:json], status: :ok
  end


  # Not implemented (obvs)
  # If you implement you MUST remove the action from skip_authorization_check above!

  def index
  	head :not_implemented
  end

  def show
  	head :not_implemented
  end

  def update
  	head :not_implemented
  end

  def destroy
  	head :not_implemented
  end
end

