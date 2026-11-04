require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:organizations).through(:memberships) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
  end

  describe "authentication" do
    it "authenticates with the correct password" do
      user = create(:user)

      expect(user.authenticate("password123")).to be_truthy
    end

    it "rejects an incorrect password" do
      user = create(:user)

      expect(user.authenticate("wrong-password")).to be_falsey
    end
  end

  describe "callbacks" do
    it "normalizes the email before validation" do
      user = build(:user, email: "  USER@EXAMPLE.COM  ")

      user.valid?

      expect(user.email).to eq("user@example.com")
    end
  end
end