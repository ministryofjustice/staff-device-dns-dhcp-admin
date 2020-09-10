class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: Rails.env.development? ? %i[cognito developer] : %i[cognito]

  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.editor = true # Temporarily set all to editor until we pull roles from cognito
    user.save
    user
  end
end
