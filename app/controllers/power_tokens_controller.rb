class PowerTokensController < ApplicationController
	def show
		token = PowerToken.find_active_token(params[:token])
		raise ActiveRecord::RecordNotFound if token.nil?

		sign_in token.user, :bypass => true	unless token.user.nil?

		redirect_to token.redirect_path
	end
end