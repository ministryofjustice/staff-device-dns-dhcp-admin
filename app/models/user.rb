class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[cognito]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create
  end
end
