require "rails_helper"

RSpec.describe "GET /sign_in", type: :feature do
  it "displays log in when not signed in" do
    visit "/"
    expect(page).to have_content "Log in"
  end

  context "user signed in" do
    before do
      # Simulate logging in via Cognito Omniauth provider
      OmniAuth.config.add_mock(:cognito, {provider: "cognito", uid: "12345"})

      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:cognito]

      visit "/sign_in"
      click_button("Sign in with Azure")
    end

    it "displays redirects to the root path if the user signs in" do
      expect(current_path).to eq "/"
      expect(page).to have_content "Subnets"
    end
  end
end
