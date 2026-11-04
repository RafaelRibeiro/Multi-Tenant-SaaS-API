require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode" do
    it "generates a valid JWT token" do
      token = described_class.encode(sub: 1)

      expect(token).to be_a(String)
      expect(token.split(".").size).to eq(3)
    end

    it "includes the user ID in the payload" do
      token = described_class.encode(sub: 123)
      decoded = described_class.decode(token)

      expect(decoded["sub"]).to eq(123)
    end

    it "includes an expiration timestamp" do
      token = described_class.encode(sub: 1)
      decoded = described_class.decode(token)

      expect(decoded["exp"]).to be_present
    end
  end

  describe ".decode" do
    it "rejects an invalid token" do
      expect {
        described_class.decode("invalid.token")
      }.to raise_error(JsonWebToken::DecodeError)
    end

    it "rejects an expired token" do
      token = described_class.encode({ sub: 1 }, 1.hour.ago)

      expect {
        described_class.decode(token)
      }.to raise_error(JsonWebToken::DecodeError)
    end
  end
end