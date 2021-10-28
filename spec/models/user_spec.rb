require "rails_helper"

describe User, type: :model do
  describe ".from_omniauth" do
    subject(:user) { User.from_omniauth(auth_hash) }
    let(:role) { "viewer" }
    let(:auth_hash) do
      # Mocking OmniAuth::AuthHash
      double(provider: "cognito", uid: "1",
             extra: double(raw_info: {"custom:app_role" => role, :identities => [double(userId: "test_from_omniauth@example.com")]}))
    end

    context "when omniauth provides an editor app role" do
      let(:role) { "editor" }

      it "sets editor to true" do
        expect(user.editor?).to eq true
      end
    end

    context "when omniauth provides a viewer app role" do
      let(:role) { "viewer" }

      it "sets viewer to true" do
        expect(user.viewer?).to eq true
      end
    end

    context "when omniauth provides a second line support role" do
      let(:role) { "second_line_support" }

      it "sets second_line_support to true" do
        expect(user.second_line_support?).to eq true
      end
    end

    it "sets the email correctly" do
      expect(user.email).to eq "test_from_omniauth@example.com"
    end
  end
end
