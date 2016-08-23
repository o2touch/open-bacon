# I think this is not used. commented to find out!
# class Api::V1::EventMessagesCommentsController < Api::V1::ApplicationController

#   def create
#     @message = EventMessage.find(params[:message_id])
#     authorize! :comment, @message

#     @comment = @message.comments.create!(text: params[:text], user: current_user)
#     AppEventService.create(@comment, current_user, "created")

#     head :created
#   end

#   # old stuff below here

#   # put /comments/1.json
#   def update
#     @comment = comment.find(params[:id])

#     if @comment.update_attributes(params[:comment])
#       respond_with head :no_content 
#     else
#       respond_with @comment.errors, status: :unprocessable_entity
#     end
#   end

#   # delete /comments/1.json
#   def destroy
#     @comment = comment.find(params[:id])
#     @comment.destroy

#     respond_with head :no_content
#   end
# end
