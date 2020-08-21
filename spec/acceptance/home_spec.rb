require "rails_helper"

RSpec.describe "GET /", type: :feature do
  it "displays hello when the user is signed in" do
    login_as User.new

    visit "/"
    expect(page).to have_content "Hello from Staff Device"
  end

  it "displays log in when not signed in" do
    visit "/"
    expect(page).to have_content "Log in"
  end
end
