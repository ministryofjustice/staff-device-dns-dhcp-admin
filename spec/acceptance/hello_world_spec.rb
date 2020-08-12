require "rails_helper"

RSpec.describe "GET /", type: :feature do
  it "displays hello" do
    visit "/"
    expect(page).to have_content "Hello from Staff Device"
  end
end
