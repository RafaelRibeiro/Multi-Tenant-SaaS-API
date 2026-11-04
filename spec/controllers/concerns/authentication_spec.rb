require "rails_helper"

RSpec.describe Authentication do
  let(:user) { create(:user) }

  let(:controller_class) do
    Class.new(ApplicationController) do
      include Authentication

      def index
        render json: {
          user_id: current_user.id
        }
      end
    end
  end

  let(:controller_instance) { controller_class.new }

  describe "#authenticate_request" do
    it "authenticates a valid token" do
      token = JsonWebToken.encode(sub: user.id)

      allow(controller_instance).to receive(:request).and_return(
        instance_double(
          ActionDispatch::Request,
          headers: { "Authorization" => "Bearer #{token}" }
        )
      )

      allow(controller_instance).to receive(:render)

      controller_instance.send(:authenticate_request)

      expect(controller_instance.send(:current_user)).to eq(user)
    end

    it "rejects a missing token" do
      allow(controller_instance).to receive(:request).and_return(
        instance_double(ActionDispatch::Request, headers: {})
      )

      allow(controller_instance).to receive(:render)

      controller_instance.send(:authenticate_request)

      expect(controller_instance).to have_received(:render).with(
        json: { error: "Unauthorized" },
        status: :unauthorized
      )
    end

    it "rejects an invalid token" do
      allow(controller_instance).to receive(:request).and_return(
        instance_double(
          ActionDispatch::Request,
          headers: { "Authorization" => "Bearer invalid.token" }
        )
      )

      allow(controller_instance).to receive(:render)

      controller_instance.send(:authenticate_request)

      expect(controller_instance).to have_received(:render).with(
        json: { error: "Unauthorized" },
        status: :unauthorized
      )
    end

    it "rejects a token belonging to a nonexistent user" do
      token = JsonWebToken.encode(sub: 999_999)

      allow(controller_instance).to receive(:request).and_return(
        instance_double(
          ActionDispatch::Request,
          headers: { "Authorization" => "Bearer #{token}" }
        )
      )

      allow(controller_instance).to receive(:render)

      controller_instance.send(:authenticate_request)

      expect(controller_instance).to have_received(:render).with(
        json: { error: "Unauthorized" },
        status: :unauthorized
      )
    end
  end
end