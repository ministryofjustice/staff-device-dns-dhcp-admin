require "rails_helper"

RSpec.describe "GET /", type: :feature do
  it "displays hello when signed in" do
    pending "Log in functionality not yet implemented"

    visit "/sign_in"
    click_link("Sign in with Cognito")
    visit "/"
    expect(page).to have_content "Hello from Staff Device"
  end

  it "displays log in when not signed in" do
    visit "/"
    expect(page).to have_content "Log in"
  end
end
