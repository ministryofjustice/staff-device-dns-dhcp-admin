class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: Rails.env.development? ? %i[cognito developer] : %i[cognito]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create
  end
end
