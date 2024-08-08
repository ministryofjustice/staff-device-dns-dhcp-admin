class User < ApplicationRecord
  MAX_SESSION_TIME = 8.hours

  enum role: {viewer: 0, second_line_support: 1, editor: 2}

  devise :omniauthable, :timeoutable, :hard_timeoutable,
    omniauth_providers: (Rails.env.development? ? %i[cognito developer] : %i[cognito]),
    hard_timeout_in: MAX_SESSION_TIME

  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = auth.extra.raw_info[:identities][0].userId
    user.role = auth.extra.raw_info["custom:app_role"]
    user.save
    user
  end

  def self.from_developer_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = auth.info.email
    user.role = :editor
    user.save
    user
  end
end
