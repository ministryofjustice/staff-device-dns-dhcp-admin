class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cognito_idp
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Cognito IDP") if is_navigational_format?
    end
  end

  def failure
    redirect_to root_path
  end
end
