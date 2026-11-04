module Api
  module V1
    class ClientsController < ApplicationController
      include Authentication

      before_action :set_organization

      def index
        clients = Current.organization.clients

        render json: {
          clients: clients.map do |client|
            {
              id: client.id,
              name: client.name,
              email: client.email,
              phone: client.phone,
              status: client.status
            }
          end
        }, status: :ok
      end

      def create
        client = Current.organization.clients.new(client_params)

        if client.save
          render json: {
            id: client.id,
            name: client.name,
            email: client.email,
            phone: client.phone,
            status: client.status
          }, status: :created
        else
          render json: { errors: client.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def show
        client = Current.organization.clients.find(params[:id])

        render json: {
          id: client.id,
          name: client.name,
          email: client.email,
          phone: client.phone,
          status: client.status
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Client not found" }, status: :not_found
      end

      def update
        client = Current.organization.clients.find(params[:id])

        if client.update(client_params)
          render json: {
            id: client.id,
            name: client.name,
            email: client.email,
            phone: client.phone,
            status: client.status
          }, status: :ok
        else
          render json: { errors: client.errors.full_messages },
                 status: :unprocessable_content
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Client not found" }, status: :not_found
      end

      def destroy
        client = Current.organization.clients.find(params[:id])
        client.destroy!

        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Client not found" }, status: :not_found
      end

      private

      def set_organization
        organization_id = request.headers["X-Organization-ID"]

        OrganizationContext.new(
          user: current_user,
          organization_id: organization_id
        ).resolve!
      rescue OrganizationContext::AccessDenied
        render json: { error: "Access to this organization is denied" },
               status: :forbidden
      end

      def client_params
        params.require(:client).permit(:name, :email, :phone, :status)
      end

    end
  end
end