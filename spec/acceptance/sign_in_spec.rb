require "rails_helper"

RSpec.describe "GET /sign_in", type: :feature do
  it "displays sign in when not signed in" do
    visit "/"
    expect(page).to have_content "Sign in"
  end

  context "user signed in" do
    before do
      # Simulate logging in via Cognito Omniauth provider
      OmniAuth.config.add_mock(:cognito, {
        provider: "cognito", uid: "12345", extra: {raw_info: {"custom:app_role": "editor"}}
      })

      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:cognito]

      visit "/sign_in"
      click_button("Sign in with Azure")
    end

    it "redirects to the root path" do
      expect(current_path).to eq "/"
      expect(page).to have_content "DHCP / DNS Admin portal"
    end
  end

  xcontext "user signed in for more than 8 hours" do
    let(:user) { User.create! }

    before do
      login_as user

      visit "/"
      expect(current_path).to eq "/"
    end

    it "signs the user out" do
      user.update!(current_sign_in_at: 10.hours.ago)

      visit "/"

      expect(current_path).to eq "/sign_in"
      expect(page).to have_content "Sign in"
    end
  end
end
