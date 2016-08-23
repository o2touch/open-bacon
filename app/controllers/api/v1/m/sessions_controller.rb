class Api::V1::M::SessionsController < Api::V1::ApplicationController

  skip_before_filter :authenticate_user!, only: [:create]
  skip_authorization_check only: [:create, :destroy]

  def create
    email = params[:email]
    password = params[:password]

    if email.blank? or password.blank?
      render status: :bad_request, json: { message: "Missing credentials" }
      return
    end

    @user=User.find_by_email(email.downcase)

    if @user.nil? or !@user.valid_password? password
      render status: :unauthorized, json: { message: "Invalid credentials" }
      return
    end

    if @user.role? RoleEnum::NO_LOGIN
      render status: :unauthorized, json: { message: "Login disabled" }
      return
    end

    @user.ensure_authentication_token!
    respond_with @user
  end

  def destroy
    current_user.reset_authentication_token!
    sign_out current_user

    sign_out current_user

    render status: :ok, json: { message: "Success" }
  end
end
