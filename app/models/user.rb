class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: Rails.env.development? ? %i[cognito developer] : %i[cognito]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.editor = true # Temporarily set all to editor until we pull roles from cognito
    end
  end
end
