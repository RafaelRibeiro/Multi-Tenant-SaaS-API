module Api
  module V1
    class OrganizationsController < ApplicationController
      include Authentication

      def select
        organization = OrganizationContext.new(
          user: current_user,
          organization_id: params[:organization_id]
        ).resolve!

        render json: {
          message: "Organization selected successfully",
          organization: {
            id: organization.id,
            name: organization.name,
            slug: organization.slug
          },
          role: Current.membership.role
        }, status: :ok
      rescue OrganizationContext::AccessDenied
        render json: {
          error: "Access to this organization is denied"
        }, status: :forbidden
      end

      def show
        organization = Organization.find(params[:id])

        authorize organization, :show?

        render json: {
          id: organization.id,
          name: organization.name,
          slug: organization.slug,
          status: organization.status
        }
      rescue ActiveRecord::RecordNotFound
        render json: {
          error: "Organization not found"
        }, status: :not_found
      end

    end
  end
end