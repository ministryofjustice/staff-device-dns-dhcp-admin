require "rails_helper"

RSpec.describe "GET /", type: :feature do
  context "user signed in" do
    before do
      OmniAuth.config.add_mock(:cognito, {provider: "cognito", uid: "12345"})

      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:cognito]

      visit "/sign_in"
      click_link("Sign in with Cognito")
    end

    it "displays hello" do
      visit "/"
      expect(page).to have_content "Hello from Staff Device"
    end
  end

  it "displays log in when not signed in" do
    visit "/"
    expect(page).to have_content "Log in"
  end
end
