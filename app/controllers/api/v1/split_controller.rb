# class Api::V1::SplitController < Api::V1::ApplicationController
#   skip_before_filter :authenticate_user!, only: [:get_alternative, :finish_split_experiment]
#   skip_authorization_check only: [:get_alternative, :finish_split_experiment]

#   def get_alternative
# 	experiment = params[:experiment_name]
 
#   	@json = {
#   		:experiment => experiment,
#   		:alternative => alternative
#   	}

#   	render json: @json
#   end
  
#   def finish_split_experiment
#   	experiment = params[:experiment_name]

#     finished(experiment)
#     head :ok
#   end
  
# end