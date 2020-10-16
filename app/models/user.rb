class User < ApplicationRecord
  EDITOR_ROLE = "editor"

  MAX_SESSION_TIME = 10.minutes

  devise :omniauthable, :timeoutable, :hard_timeoutable,
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
end
