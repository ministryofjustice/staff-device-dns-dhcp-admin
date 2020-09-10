class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :developer

  def cognito
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user
  end

  def developer
    @user = User.where(provider: "developer", editor: true).first_or_create
    sign_in_and_redirect @user
  end

  def failure
    redirect_to root_path
  end
end
