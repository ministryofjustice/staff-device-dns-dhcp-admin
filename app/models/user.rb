class User < ApplicationRecord
  EDITOR_ROLE = "editor"

  MAX_SESSION_TIME = 8.hours

  devise :omniauthable, :timeoutable, :trackable, :hard_timeoutable,
    omniauth_providers: (Rails.env.development? ? %i[cognito developer] : %i[cognito]),
    hard_timeout_in: MAX_SESSION_TIME

  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.editor = auth.extra.raw_info["custom:app_role"] == EDITOR_ROLE
    user.save
    user
  end

  def self.from_developer_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.editor = true
    user.save
    user
  end

  protected

  # Method called by devise Trackable module to track IPs
  # Removing this method will result in IPs being logged in the user table
  def extract_ip_from(request)
    # Skip IP logging in Trackable module
  end
end
